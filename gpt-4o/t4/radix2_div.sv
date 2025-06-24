module radix2_div(
    input wire clk,
    input wire rst,
    input wire sign,
    input wire [7:0] dividend,
    input wire [7:0] divisor,
    input wire opn_valid,
    output reg res_valid,
    output reg [15:0] result
);

    reg [15:0] SR;
    reg [7:0] NEG_DIVISOR;
    reg [3:0] cnt;
    reg start_cnt;
    wire [8:0] subtraction_result;
    wire carry_out;
    wire [7:0] abs_dividend;
    wire [7:0] abs_divisor;
    wire dividend_sign;
    wire divisor_sign;

    assign dividend_sign = sign ? dividend[7] : 1'b0;
    assign divisor_sign = sign ? divisor[7] : 1'b0;
    assign abs_dividend = dividend_sign ? (~dividend + 1'b1) : dividend;
    assign abs_divisor = divisor_sign ? (~divisor + 1'b1) : divisor;

    assign subtraction_result = {SR[14:7]} - {1'b0, NEG_DIVISOR};
    assign carry_out = ~subtraction_result[8];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res_valid <= 1'b0;
            SR <= 16'b0;
            NEG_DIVISOR <= 8'b0;
            cnt <= 4'b0;
            start_cnt <= 1'b0;
        end else if (opn_valid && !res_valid) begin
            SR <= {abs_dividend, 1'b0};
            NEG_DIVISOR <= ~abs_divisor + 1'b1;
            cnt <= 4'b1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            if (cnt[3]) begin
                cnt <= 4'b0;
                start_cnt <= 1'b0;
                res_valid <= 1'b1;
                result <= {SR[14:7], SR[6:0]};
                if (sign && (dividend_sign ^ divisor_sign)) begin
                    result[7:0] <= ~SR[6:0] + 1'b1;
                end
                if (sign && dividend_sign) begin
                    result[15:8] <= ~SR[14:7] + 1'b1;
                end
            end else begin
                cnt <= cnt + 1'b1;
                SR <= {subtraction_result[7:0], SR[6:0], carry_out};
            end
        end
    end

endmodule