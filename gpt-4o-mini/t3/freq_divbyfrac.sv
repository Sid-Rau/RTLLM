module freq_divbyfrac (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);
    reg [2:0] counter;
    reg clk_int1, clk_int2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'b000;
            clk_int1 <= 1'b0;
            clk_int2 <= 1'b0;
            clk_div <= 1'b0;
        end else begin
            if (counter < 3'b111) begin
                counter <= counter + 1;
            end else begin
                counter <= 3'b000;
            end
            if (counter < 3'b100) begin
                clk_int1 <= 1'b1; // 4 clock cycles
            end else begin
                clk_int1 <= 1'b0;
            end
            if (counter < 3'b011) begin
                clk_int2 <= 1'b1; // 3 clock cycles
            end else begin
                clk_int2 <= 1'b0;
            end
            clk_div <= clk_int1 | clk_int2;
        end
    end
endmodule