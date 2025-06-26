module radix2_div (
    input wire clk,
    input wire rst,
    input wire sign,
    input wire [7:0] dividend,
    input wire [7:0] divisor,
    input wire opn_valid,
    output reg res_ready,
    output reg res_valid,
    output reg [15:0] result
);
    reg [7:0] abs_dividend;
    reg [7:0] abs_divisor;
    reg [8:0] SR;
    reg [3:0] cnt;
    reg start_cnt;
    reg [7:0] NEG_DIVISOR;
    reg [7:0] quotient;
    reg [7:0] remainder;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res_valid <= 0;
            res_ready <= 0;
            cnt <= 0;
            start_cnt <= 0;
            SR <= 0;
            result <= 0;
        end else begin
            if (opn_valid && !res_valid) begin
                abs_dividend <= (sign && dividend[7]) ? ~dividend + 1 : dividend;
                abs_divisor <= (sign && divisor[7]) ? ~divisor + 1 : divisor;
                NEG_DIVISOR <= ~abs_divisor + 1;
                SR <= {1'b0, abs_dividend};
                cnt <= 1;
                start_cnt <= 1;
                res_valid <= 0;
            end

            if (start_cnt) begin
                if (cnt == 8) begin
                    start_cnt <= 0;
                    res_valid <= 1;
                    result <= {remainder, quotient};
                end else begin
                    cnt <= cnt + 1;
                    if (SR[8:1] >= abs_divisor) begin
                        SR[8:1] <= SR[8:1] + NEG_DIVISOR;
                        SR[0] <= 1;
                    end else begin
                        SR[0] <= 0;
                    end
                    SR <= {SR[7:0], 1'b0};
                    quotient <= {quotient[6:0], SR[0]};
                    remainder <= SR[8:1];
                end
            end

            if (res_valid && res_ready) begin
                res_valid <= 0;
                res_ready <= 0;
            end
        end
    end
endmodule