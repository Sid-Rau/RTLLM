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
    reg [8:0] SR;
    reg [7:0] NEG_DIVISOR;
    reg [3:0] cnt;
    reg start_cnt;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res_valid <= 0;
            cnt <= 0;
            start_cnt <= 0;
            result <= 0;
        end else begin
            if (opn_valid && !res_valid) begin
                SR <= {1'b0, dividend} << 1;
                NEG_DIVISOR <= ~divisor + 1;
                cnt <= 1;
                start_cnt <= 1;
                res_valid <= 0;
            end
            
            if (start_cnt) begin
                if (cnt == 8) begin
                    start_cnt <= 0;
                    res_valid <= 1;
                    result <= {SR[8:1], SR[0]};
                end else begin
                    cnt <= cnt + 1;
                    SR <= {SR[7:0], 1'b0};
                    if (SR[8:1] >= NEG_DIVISOR) begin
                        SR[8:1] <= SR[8:1] + NEG_DIVISOR;
                        SR[0] <= 1;
                    end else begin
                        SR[0] <= 0;
                    end
                end
            end
        end
    end
endmodule