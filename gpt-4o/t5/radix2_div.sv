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
    reg [7:0] abs_dividend, abs_divisor;
    reg dividend_sign, divisor_sign;
    wire [8:0] sub_res;
    wire carry_out;

    assign sub_res = {SR[15:8], SR[7]} - {1'b0, NEG_DIVISOR};
    assign carry_out = ~sub_res[8];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res_valid <= 0;
            result <= 0;
            SR <= 0;
            NEG_DIVISOR <= 0;
            cnt <= 0;
            start_cnt <= 0;
        end else begin
            if (opn_valid && !res_valid) begin
                if (sign) begin
                    abs_dividend = dividend[7] ? ~dividend + 1 : dividend;
                    abs_divisor = divisor[7] ? ~divisor + 1 : divisor;
                    dividend_sign = dividend[7];
                    divisor_sign = divisor[7];
                end else begin
                    abs_dividend = dividend;
                    abs_divisor = divisor;
                    dividend_sign = 0;
                    divisor_sign = 0;
                end
                SR <= {abs_dividend, 1'b0};
                NEG_DIVISOR <= ~abs_divisor + 1;
                cnt <= 1;
                start_cnt <= 1;
            end else if (start_cnt) begin
                if (cnt == 8) begin
                    cnt <= 0;
                    start_cnt <= 0;
                    res_valid <= 1;
                    result[7:0] <= (dividend_sign ^ divisor_sign) ? ~SR[7:0] + 1 : SR[7:0];
                    result[15:8] <= dividend_sign ? ~SR[15:8] + 1 : SR[15:8];
                end else begin
                    cnt <= cnt + 1;
                    if (carry_out)
                        SR <= {sub_res[7:0], SR[6:0], 1'b1};
                    else
                        SR <= {SR[14:0], 1'b0};
                end
            end else if (res_valid) begin
                if (!opn_valid) begin
                    res_valid <= 0;
                end
            end
        end
    end

endmodule