module freq_divbyfrac (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);
    reg [2:0] count;
    reg clk_int1, clk_int2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 3'b000;
            clk_int1 <= 1'b0;
            clk_int2 <= 1'b0;
            clk_div <= 1'b0;
        end else begin
            if (count < 3'b100) begin
                count <= count + 1;
            end else begin
                count <= 3'b000;
            end
            
            if (count < 3'b100) begin
                clk_int1 <= (count < 3'b100) ? 1'b1 : 1'b0;
                clk_int2 <= (count < 3'b011) ? 1'b1 : 1'b0;
            end else begin
                clk_int1 <= 1'b0;
                clk_int2 <= 1'b0;
            end
            
            clk_div <= clk_int1 | clk_int2;
        end
    end
endmodule