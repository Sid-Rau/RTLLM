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

    reg [15:0] SR;
    reg [7:0] NEG_DIVISOR;
    reg [3:0] cnt;
    reg start_cnt;
    reg [7:0] abs_dividend, abs_divisor;
    reg dividend_sign, divisor_sign;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res_valid <= 0;
            result <= 0;
            SR <= 0;
            NEG_DIVISOR <= 0;
            cnt <= 0;
            start_cnt <= 0;
            abs_dividend <= 0;
            abs_divisor <= 0;
            dividend_sign <= 0;
            divisor_sign <= 0;
        end else begin
            if (opn_valid && !res_valid) begin
                if (sign) begin
                    abs_dividend <= dividend[7] ? -dividend : dividend;
                    abs_divisor <= divisor[7] ? -divisor : divisor;
                    dividend_sign <= dividend[7];
                    divisor_sign <= divisor[7];
                end else begin
                    abs_dividend <= dividend;
                    abs_divisor <= divisor;
                    dividend_sign <= 0;
                    divisor_sign <= 0;
                end

                SR <= {abs_dividend, 8'b0};
                NEG_DIVISOR <= -abs_divisor;
                cnt <= 1;
                start_cnt <= 1;
            end else if (start_cnt) begin
                if (cnt == 8) begin
                    cnt <= 0;
                    start_cnt <= 0;
                    res_valid <= 1;
                    if (dividend_sign ^ divisor_sign) begin
                        result <= {SR[15:8], -SR[7:0]};
                    end else begin
                        result <= SR;
                    end
                end else begin
                    cnt <= cnt + 1;
                    if (SR[15]) begin
                        SR <= {SR[14:0], 1'b0} + {NEG_DIVISOR, 8'b0};
                    end else begin
                        SR <= {SR[14:0], 1'b0} + {abs_divisor, 8'b0};
                    end
                end
            end else if (res_valid) begin
                res_valid <= 0;
            end
        end
    end

endmodule