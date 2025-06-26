module freq_divbyodd #(
    parameter NUM_DIV = 5 // Odd divisor value
) (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);

    localparam CNT_MAX = NUM_DIV - 1;
    localparam TOGGLE_POINT = (NUM_DIV + 1) / 2 - 1;

    reg [($clog2(NUM_DIV) == 0 ? 1 : $clog2(NUM_DIV))-1:0] cnt1;
    reg [($clog2(NUM_DIV) == 0 ? 1 : $clog2(NUM_DIV))-1:0] cnt2;

    reg clk_div1;
    reg clk_div2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt1 <= 0;
            clk_div1 <= 0;
        end else begin
            if (cnt1 == CNT_MAX) begin
                cnt1 <= 0;
            end else begin
                cnt1 <= cnt1 + 1;
            end

            if (cnt1 == TOGGLE_POINT) begin
                clk_div1 <= ~clk_div1;
            end
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt2 <= 0;
            clk_div2 <= 0;
        end else begin
            if (cnt2 == CNT_MAX) begin
                cnt2 <= 0;
            end else begin
                cnt2 <= cnt2 + 1;
            end

            if (cnt2 == TOGGLE_POINT) begin
                clk_div2 <= ~clk_div2;
            end
        end
    end

    always @(*) begin
        clk_div = clk_div1 | clk_div2;
    end

endmodule