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
reg result_sign;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        SR <= 0;
        cnt <= 0;
        start_cnt <= 0;
        res_valid <= 0;
        quotient <= 0;
        remainder <= 0;
        result <= 0;
    end else begin
        if (opn_valid && !res_valid && !start_cnt) begin
            dividend_sign = sign & dividend[7];
            divisor_sign = sign & divisor[7];
            result_sign = dividend_sign ^ divisor_sign;
            abs_dividend = dividend_sign ? -dividend : dividend;
            abs_divisor = divisor_sign ? -divisor : divisor;
            NEG_DIVISOR = -abs_divisor;
            SR = {8'b0, abs_dividend};
            cnt <= 1;
            start_cnt <= 1;
        end

        if (start_cnt) begin
            if (cnt[3]) begin
                remainder = SR[15:8];
                quotient = SR[7:0];
                if (result_sign) quotient = -quotient;
                if (dividend_sign) remainder = -remainder;
                result <= {remainder, quotient};
                res_valid <= 1;
                start_cnt <= 0;
                cnt <= 0;
            end else begin
                SR = SR << 1;
                if (SR[15:8] >= abs_divisor) begin
                    SR[15:8] = SR[15:8] + NEG_DIVISOR;
                    SR[0] = 1;
                end
                cnt <= cnt + 1;
            end
        end

        if (res_valid && opn_valid) begin
            res_valid <= 0;
        end
    end
end

endmodule