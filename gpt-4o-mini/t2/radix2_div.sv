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
    reg [7:0] NEG_DIVISOR;

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
                abs_dividend = (sign && dividend[7]) ? ~dividend + 1 : dividend;
                abs_divisor = (sign && divisor[7]) ? ~divisor + 1 : divisor;
                NEG_DIVISOR = ~abs_divisor + 1;
                SR = {abs_dividend, 1'b0};
                cnt = 1;
                start_cnt = 1;
            end
            
            if (start_cnt) begin
                if (cnt == 8) begin
                    start_cnt = 0;
                    res_valid = 1;
                    result = SR;
                    res_ready = 1;
                end else begin
                    SR = {SR[14:0], 1'b0};
                    SR[7:0] = SR[7:0] + NEG_DIVISOR;
                    if (SR[7]) begin
                        SR[7:0] = SR[7:0] - NEG_DIVISOR;
                        SR[15] = 1;
                    end else begin
                        SR[15] = 0;
                    end
                    cnt = cnt + 1;
                end
            end
            
            if (res_ready) begin
                res_ready = 0;
            end
        end
    end
endmodule