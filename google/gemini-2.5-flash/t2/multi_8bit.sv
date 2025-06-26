module multi_8bit (
    input  [7:0] A,
    input  [7:0] B,
    output [15:0] product
);

reg [15:0] current_product;
reg [15:0] shifted_A;
integer i;

always @(*) begin
    current_product = 16'b0;
    shifted_A = {8'b0, A}; // Initialize shifted_A with A, padded to 16 bits

    for (i = 0; i < 8; i = i + 1) begin
        if (B[i] == 1'b1) begin
            current_product = current_product + shifted_A;
        end
        shifted_A = shifted_A << 1; // Shift A left for the next iteration
    end
    product = current_product;
end

endmodule