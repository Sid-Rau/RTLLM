module multi_8bit (
    input  [7:0] A,
    input  [7:0] B,
    output [15:0] product
);

reg [15:0] prod_reg;
reg [7:0]  multiplicand_reg;
reg [7:0]  multiplier_reg;
integer    i;

always @(*) begin
    prod_reg = 16'h0000;
    multiplicand_reg = A;
    multiplier_reg = B;

    for (i = 0; i < 8; i = i + 1) begin
        if (multiplier_reg[0]) begin
            prod_reg = prod_reg + {8'h00, multiplicand_reg};
        end
        multiplicand_reg = multiplicand_reg << 1;
        multiplier_reg = multiplier_reg >> 1;
    end
    product = prod_reg;
end

endmodule