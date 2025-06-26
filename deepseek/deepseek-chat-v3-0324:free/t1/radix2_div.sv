module radix2_div (
    input clk,
    input rst,
    input sign,
    input [7:0] dividend,
    input [7:0] divisor,
    input opn_valid,
    input res_ready,
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
    reg sign_q;
    reg sign_r;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            SR <= 0;
            cnt <= 0;
            start_cnt <= 0;
            res_valid <= 0;
            result <= 0;
            quotient <= 0;
            remainder <= 0;
            sign_q <= 0;
            sign_r <= 0;
        end else begin
            if (opn_valid && !res_valid && !start_cnt) begin
                abs_dividend = sign && dividend[7] ? -dividend : dividend;
                abs_divisor = sign && divisor[7] ? -divisor : divisor;
                NEG_DIVISOR = -abs_divisor;
                SR = {8'b0, abs_dividend} << 1;
                cnt <= 1;
                start_cnt <= 1;
                sign_q <= sign && (dividend[7] ^ divisor[7]);
                sign_r <= sign && dividend[7];
            end

            if (start_cnt) begin
                if (cnt[3]) begin
                    quotient <= sign_q ? -SR[7:0] : SR[7:0];
                    remainder <= sign_r ? -SR[15:8] : SR[15:8];
                    cnt <= 0;
                    start_cnt <= 0;
                    res_valid <= 1;
                    result <= {remainder, quotient};
                end else begin
                    SR = {SR[14:0], 1'b0};
                    if (SR[15:8] + NEG_DIVISOR >= 0) begin
                        SR[15:8] = SR[15:8] + NEG_DIVISOR;
                        SR[0] = 1'b1;
                    end
                    cnt <= cnt + 1;
                end
            end

            if (res_valid && res_ready) begin
                res_valid <= 0;
            end
        end
    end

endmodule