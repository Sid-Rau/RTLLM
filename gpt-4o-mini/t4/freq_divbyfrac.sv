module freq_divbyfrac (
    input clk,
    input rst_n,
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
            if (counter < 3) begin
                counter <= counter + 1;
                clk_int1 <= 1'b1;
                clk_int2 <= 1'b0;
            end else if (counter < 7) begin
                counter <= counter + 1;
                clk_int1 <= 1'b0;
                clk_int2 <= 1'b1;
            end else begin
                counter <= 3'b000;
                clk_int1 <= 1'b0;
                clk_int2 <= 1'b0;
            end
            clk_div <= clk_int1 | clk_int2;
        end
    end
endmodule