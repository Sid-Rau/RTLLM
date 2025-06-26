module multi_8bit (
    input [7:0] A,
    input [7:0] B,
    output reg [15:0] product
);

    reg [15:0] temp_product;
    reg [7:0] temp_A;
    integer i;

    always @* begin
        temp_product = 16'b0;
        temp_A = A;
        
        for (i = 0; i < 8; i = i + 1) begin
            if (B[i]) begin
                temp_product = temp_product + (temp_A << i);
            end
        end
        
        product = temp_product;
    end

endmodule