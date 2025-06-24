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
    reg [15:0] sr;
    reg [7:0] neg_divisor;
    reg [3:0] cnt;
    reg start_cnt;
    reg [7:0] abs_dividend, abs_divisor;
    reg dividend_sign, divisor_sign;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res_valid <= 0;
            result <= 0;
            sr <= 0;
            neg_divisor <= 0;
            cnt <= 0;
            start_cnt <= 0;
        end else begin
            if (opn_valid && !res_valid) begin
                dividend_sign <= sign ? dividend[7] : 0;
                divisor_sign <= sign ? divisor[7] : 0;
                abs_dividend <= sign && dividend[7] ? -dividend : dividend;
                abs_divisor <= sign && divisor[7] ? -divisor : divisor;
                sr <= {abs_dividend, 8'b0};
                neg_divisor <= ~abs_divisor + 1;
                cnt <= 1;
                start_cnt <= 1;
            end

            if (start_cnt) begin
                if (cnt[3]) begin
                    cnt <= 0;
                    start_cnt <= 0;
                    res_valid <= 1;
                    if (dividend_sign != divisor_sign)
                        sr[7:0] <= -sr[7:0];
                    if (dividend_sign)
                        sr[15:8] <= -sr[15:8];
                    result <= sr;
                end else begin
                    cnt <= cnt + 1;
                    if (sr[15:8] + neg_divisor[7:0] >= 0)
                        sr <= {sr[14:0], 1'b1} + {neg_divisor, 8'b0};
                    else
                        sr <= {sr[14:0], 1'b0};
                end
            end

            if (res_valid && !opn_valid) begin
                res_valid <= 0;
            end
        end
    end
endmodule