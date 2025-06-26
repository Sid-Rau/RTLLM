module radix2_div (
    input clk,
    input rst,
    input sign,
    input [7:0] dividend,
    input [7:0] divisor,
    input opn_valid,
    output reg res_ready,
    output reg res_valid,
    output reg [15:0] result
);
    reg [7:0] abs_dividend;
    reg [7:0] abs_divisor;
    reg [15:0] SR;
    reg [3:0] cnt;
    reg start_cnt;
    wire [15:0] neg_divisor;
    wire [15:0] sub_result;
    wire carry_out;

    assign neg_divisor = {8'b0, ~abs_divisor + 1'b1};

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res_valid <= 0;
            res_ready <= 0;
            cnt <= 0;
            start_cnt <= 0;
        end else begin
            if (opn_valid && !res_valid) begin
                abs_dividend <= sign ? dividend[7] ? ~dividend + 1 : dividend : dividend;
                abs_divisor <= sign ? divisor[7] ? ~divisor + 1 : divisor : divisor;
                SR <= {abs_dividend, 1'b0};
                cnt <= 1;
                start_cnt <= 1;
            end
            
            if (start_cnt) begin
                if (cnt == 8) begin
                    result <= {SR[15:8], SR[7:0]};
                    res_valid <= 1;
                    start_cnt <= 0;
                    cnt <= 0;
                end else begin
                    {carry_out, sub_result} <= SR[15:8] + neg_divisor;
                    SR <= {SR[14:0], carry_out};
                    if (carry_out) begin
                        SR[15:8] <= sub_result;
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