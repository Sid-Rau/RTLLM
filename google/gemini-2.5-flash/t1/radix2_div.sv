module radix2_div (
    input clk,
    input rst,
    input sign,
    input [7:0] dividend,
    input [7:0] divisor,
    input opn_valid,
    output reg res_ready,
    output reg res_valid,
    output reg [15:0] result
);

reg [15:0] SR;
reg [7:0] NEG_DIVISOR;
reg [3:0] cnt;
reg start_cnt;
reg [7:0] abs_dividend;
reg [7:0] abs_divisor;
reg dividend_neg;
reg divisor_neg;
reg quotient_neg;

always @(*) begin
    abs_dividend = dividend;
    dividend_neg = 1'b0;
    if (sign && dividend[7]) begin
        abs_dividend = ~dividend + 1'b1;
        dividend_neg = 1'b1;
    end

    abs_divisor = divisor;
    divisor_neg = 1'b0;
    if (sign && divisor[7]) begin
        abs_divisor = ~divisor + 1'b1;
        divisor_neg = 1'b1;
    end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        SR <= 16'b0;
        NEG_DIVISOR <= 8'b0;
        cnt <= 4'b0;
        start_cnt <= 1'b0;
        res_valid <= 1'b0;
        result <= 16'b0;
        res_ready <= 1'b0;
        quotient_neg <= 1'b0;
    end else begin
        res_ready <= 1'b0; 

        if (opn_valid && !res_valid) begin
            SR <= {abs_dividend, 8'b0};
            NEG_DIVISOR <= ~abs_divisor + 1'b1;
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
            quotient_neg = (dividend_neg ^ divisor_neg);
        end else if (start_cnt) begin
            if (cnt == 4'd8) begin
                start_cnt <= 1'b0;
                cnt <= 4'b0;
                res_valid <= 1'b1;

                if (sign) begin
                    reg [7:0] final_remainder;
                    reg [7:0] final_quotient;

                    final_remainder = SR[15:8];
                    final_quotient = SR[7:0];

                    if (dividend_neg && final_remainder != 8'b0) begin
                        final_remainder = ~final_remainder + 1'b1;
                    end

                    if (quotient_neg) begin
                        final_quotient = ~final_quotient + 1'b1;
                    end
                    result <= {final_remainder, final_quotient};
                end else begin
                    result <= SR;
                end
            end else begin
                reg [8:0] temp_sub;
                reg carry_out;
                
                temp_sub = SR[15:8] + NEG_DIVISOR;
                carry_out = temp_sub[8];

                if (carry_out) begin // SR[15:8] >= abs_divisor
                    SR <= {temp_sub[7:0], SR[7:0], 1'b1};
                end else begin // SR[15:8] < abs_divisor
                    SR <= {SR[15:8], SR[7:0], 1'b0};
                end
                SR <= SR << 1;
                SR[0] = carry_out;
                
                cnt <= cnt + 1'b1;
            end
        end

        if (res_valid && res_ready) begin
            res_valid <= 1'b0;
        end
    end
end

endmodule