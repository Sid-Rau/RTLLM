module multi_8bit (
    input  [7:0] A,
    input  [7:0] B,
    output [15:0] product
);

    reg [15:0] prod_reg;
    reg [15:0] multiplicand_shifted;
    integer i;

    always @(*) begin
        prod_reg = 16'd0;
        multiplicand_shifted = {8'd0, A}; // Initialize with A, padded to 16 bits

        for (i = 0; i < 8; i = i + 1) begin
            if (B[i] == 1'b1) begin
                prod_reg = prod_reg + multiplicand_shifted;
            end
            multiplicand_shifted = multiplicand_shifted << 1;
        end
    end

    assign product = prod_reg;

endmodule