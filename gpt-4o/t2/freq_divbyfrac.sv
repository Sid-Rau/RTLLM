module freq_divbyfrac (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);

reg [2:0] counter;
reg clk_div_int1, clk_div_int2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        counter <= 3'b000;
        clk_div_int1 <= 1'b0;
    end else begin
        if (counter == 3'b011) begin
            clk_div_int1 <= ~clk_div_int1;
            counter <= counter + 1'b1;
        end else if (counter == 3'b110) begin
            clk_div_int1 <= ~clk_div_int1;
            counter <= 3'b000;
        end else begin
            counter <= counter + 1'b1;
        end
    end
end

always @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
        clk_div_int2 <= 1'b0;
    end else begin
        if (counter == 3'b011 || counter == 3'b110) begin
            clk_div_int2 <= ~clk_div_int2;
        end
    end
end

always @(*) begin
    clk_div = clk_div_int1 | clk_div_int2;
end

endmodule