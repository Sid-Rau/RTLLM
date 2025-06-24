module multi_8bit(
    input [7:0] A,
    input [7:0] B,
    output reg [15:0] product
);
    integer i;
    reg [15:0] multiplicand;
    reg [15:0] temp_product;
    
    always @(*) begin
        multiplicand = {8'b0, A};
        temp_product = 16'b0;
        for (i = 0; i < 8; i = i + 1) begin
            if (B[i])
                temp_product = temp_product + (multiplicand << i);
        end
        product = temp_product;
    end
endmodule