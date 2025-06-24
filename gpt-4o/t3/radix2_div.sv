module radix2_div (
    input wire clk,
    input wire rst,
    input wire sign,
    input wire [7:0] dividend,
    input wire [7:0] divisor,
    input wire opn_valid,
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
            sr <= 16'b0;
            neg_divisor <= 8'b0;
            cnt <= 4'b0;
            start_cnt <= 1'b0;
            res_valid <= 1'b0;
            result <= 16'b0;
        end else if (opn_valid && !res_valid) begin
            abs_dividend <= sign && dividend[7] ? -dividend : dividend;
            abs_divisor <= sign && divisor[7] ? -divisor : divisor;
            dividend_sign <= sign && dividend[7];
            divisor_sign <= sign && divisor[7];
            sr <= {abs_dividend, 8'b0};
            neg_divisor <= ~abs_divisor + 1;
            cnt <= 4'b0001;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            if (cnt[3]) begin
                cnt <= 4'b0;
                start_cnt <= 1'b0;
                res_valid <= 1'b1;
                if (dividend_sign != divisor_sign) begin
                    result[7:0] <= ~sr[7:0] + 1;
                end else begin
                    result[7:0] <= sr[7:0];
                end
                if (dividend_sign) begin
                    result[15:8] <= ~sr[15:8] + 1;
                end else begin
                    result[15:8] <= sr[15:8];
                end
            end else begin
                cnt <= cnt + 1;
                if (sr[15] == 1'b0) begin
                    sr <= {sr[14:0], 1'b0} + {neg_divisor, 8'b0};
                end else begin
                    sr <= {sr[14:0], 1'b0};
                end
                sr[0] <= ~sr[15];
            end
        end else if (res_valid) begin
            res_valid <= 1'b0;
        end
    end

endmodule