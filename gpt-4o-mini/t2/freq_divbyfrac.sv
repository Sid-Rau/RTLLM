module freq_divbyfrac(
    input clk,
    input rst_n,
    output reg clk_div
);

parameter MUL2_DIV_CLK = 7;
reg [2:0] counter;
reg clk_int1, clk_int2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 0;
        clk_int1 <= 0;
        clk_int2 <= 0;
        clk_div <= 0;
    end else begin
        if (counter < 4) begin
            clk_int1 <= 1;
        end else if (counter < 7) begin
            clk_int1 <= 0;
        end
        
        if (counter < 3) begin
            clk_int2 <= 1;
        end else if (counter < 6) begin
            clk_int2 <= 0;
        end
        
        if (counter == MUL2_DIV_CLK - 1) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
        
        clk_div <= clk_int1 | clk_int2;
    end
end

endmodule