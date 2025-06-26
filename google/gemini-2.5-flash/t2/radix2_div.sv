module radix2_div (
    input wire clk,
    input wire rst,
    input wire sign,
    input wire [7:0] dividend,
    input wire [7:0] divisor,
    input wire opn_valid,
    input wire res_ready,
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

always @(posedge clk or posedge rst) begin
    if (rst) begin
        SR <= 16'h0000;
        NEG_DIVISOR <= 8'h00;
        cnt <= 4'h0;
        start_cnt <= 1'b0;
        res_valid <= 1'b0;
        abs_dividend <= 8'h00;
        abs_divisor <= 8'h00;
        dividend_neg <= 1'b0;
        divisor_neg <= 1'b0;
        result <= 16'h0000;
    end else begin
        if (opn_valid && !res_valid) begin
            dividend_neg <= (sign && dividend[7]);
            divisor_neg <= (sign && divisor[7]);

            abs_dividend <= (sign && dividend[7]) ? (~dividend + 1'b1) : dividend;
            abs_divisor <= (sign && divisor[7]) ? (~divisor + 1'b1) : divisor;
            
            SR <= {abs_dividend, 8'h00};
            NEG_DIVISOR <= (~abs_divisor + 1'b1);
            cnt <= 4'h0;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            reg [8:0] sub_result;
            reg cout;

            sub_result = SR[15:8] + NEG_DIVISOR;
            cout = sub_result[8];

            if (cnt == 4'd8) begin
                start_cnt <= 1'b0;
                cnt <= 4'h0;
                res_valid <= 1'b1;

                reg [7:0] final_quotient;
                reg [7:0] final_remainder;

                final_quotient = SR[7:0];
                final_remainder = SR[15:8];

                if (sign) begin
                    if (dividend_neg != divisor_neg) begin
                        final_quotient = ~final_quotient + 1'b1;
                    end
                    if (dividend_neg) begin
                        final_remainder = ~final_remainder + 1'b1;
                    end
                end
                result <= {final_remainder, final_quotient};
            end else begin
                cnt <= cnt + 1'b1;
                if (cout == 1'b1) begin
                    SR <= {sub_result[7:0], SR[7:0], 1'b1};
                end else begin
                    SR <= {SR[14:8], SR[7:0], 1'b0};
                end
            end
        end else if (res_valid && res_ready) begin
            res_valid <= 1'b0;
        end
    end
end

endmodule