module multi_8bit (
    input  [7:0] A,
    input  [7:0] B,
    output [15:0] product
);

reg [15:0] prod_reg;
reg [7:0]  multiplicand_shifted;
integer i;

always @(*) begin
    prod_reg = 16'b0;
    multiplicand_shifted = A;

    for (i = 0; i < 8; i = i + 1) begin
        if (B[i] == 1'b1) begin
            prod_reg = prod_reg + (multiplicand_shifted << i);
        end
    end
end

assign product = prod_reg;

endmodule