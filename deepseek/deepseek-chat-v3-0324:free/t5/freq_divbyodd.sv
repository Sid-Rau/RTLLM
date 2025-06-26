module freq_divbyodd (
    input clk,
    input rst_n,
    output clk_div
);

parameter NUM_DIV = 5;
localparam CNT_MAX = NUM_DIV - 1;
localparam CNT_HALF = (NUM_DIV - 1) / 2;

reg [31:0] cnt1, cnt2;
reg clk_div1, clk_div2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt1 <= 0;
        clk_div1 <= 0;
    end
    else begin
        if (cnt1 == CNT_MAX) begin
            cnt1 <= 0;
            clk_div1 <= ~clk_div1;
        end
        else begin
            cnt1 <= cnt1 + 1;
            if (cnt1 == CNT_HALF) begin
                clk_div1 <= ~clk_div1;
            end
        end
    end
end

always @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt2 <= 0;
        clk_div2 <= 0;
    end
    else begin
        if (cnt2 == CNT_MAX) begin
            cnt2 <= 0;
            clk_div2 <= ~clk_div2;
        end
        else begin
            cnt2 <= cnt2 + 1;
            if (cnt2 == CNT_HALF) begin
                clk_div2 <= ~clk_div2;
            end
        end
    end
end

assign clk_div = clk_div1 | clk_div2;

endmodule