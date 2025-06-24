module freq_diveven #(parameter NUM_DIV = 2) (
    input clk,
    input rst_n,
    output reg clk_div
);
    reg [3:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            clk_div <= 0;
        end else begin
            if (cnt < (NUM_DIV / 2) - 1) begin
                cnt <= cnt + 1;
            end else begin
                cnt <= 0;
                clk_div <= ~clk_div;
            end
        end
    end
endmodule