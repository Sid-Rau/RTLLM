module freq_divbyfrac (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);

reg [2:0] counter;
reg clk_div_1, clk_div_2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 3'b000;
        clk_div_1 <= 1'b0;
    end else begin
        if (counter < 3) begin
            clk_div_1 <= ~clk_div_1;
            counter <= counter + 1;
        end else begin
            clk_div_1 <= clk_div_1;
            counter <= counter + 1;
        end
        if (counter == 6)
            counter <= 3'b000;
    end
end

always @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_div_2 <= 1'b0;
    end else begin
        if (counter < 3) begin
            clk_div_2 <= ~clk_div_2;
        end else begin
            clk_div_2 <= clk_div_2;
        end
    end
end

always @(*) begin
    clk_div = clk_div_1 | clk_div_2;
end

endmodule