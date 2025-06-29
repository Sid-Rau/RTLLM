module radix2_div (
    input clk,
    input rst,
    input sign,
    input [7:0] dividend,
    input [7:0] divisor,
    input opn_valid,
    output reg res_valid,
    output reg [15:0] result
);

reg [7:0] abs_dividend;
reg [7:0] abs_divisor;
reg [15:0] SR;
reg [7:0] NEG_DIVISOR;
reg [3:0] cnt;
reg start_cnt;
reg [7:0] quotient;
reg [7:0] remainder;
reg dividend_sign;
reg divisor_sign;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        SR <= 16'b0;
        cnt <= 4'b0;
        start_cnt <= 1'b0;
        res_valid <= 1'b0;
        result <= 16'b0;
        quotient <= 8'b0;
        remainder <= 8'b0;
    end else begin
        if (opn_valid && !res_valid) begin
            dividend_sign = sign & dividend[7];
            divisor_sign = sign & divisor[7];
            abs_dividend = dividend_sign ? -dividend : dividend;
            abs_divisor = divisor_sign ? -divisor : divisor;
            SR <= {8'b0, abs_dividend} << 1;
            NEG_DIVISOR <= -abs_divisor;
            cnt <= 4'b1;
            start_cnt <= 1'b1;
        end

        if (start_cnt) begin
            if (cnt[3]) begin
                start_cnt <= 1'b0;
                cnt <= 4'b0;
                remainder = SR[15:8];
                quotient = SR[7:0];
                if (sign) begin
                    if (dividend_sign ^ divisor_sign) quotient = -quotient;
                    if (dividend_sign) remainder = -remainder;
                end
                result <= {remainder, quotient};
                res_valid <= 1'b1;
            end else begin
                cnt <= cnt + 1;
                if (SR[15:8] + NEG_DIVISOR >= 0) begin
                    SR <= {SR[14:8] + NEG_DIVISOR, SR[7:0], 1'b1};
                end else begin
                    SR <= {SR[14:0], 1'b0};
                end
            end
        end

        if (res_valid && opn_valid) begin
            res_valid <= 1'b0;
        end
    end
end

endmodule