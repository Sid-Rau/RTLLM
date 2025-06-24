module multi_8bit (
    input [7:0] A,
    input [7:0] B,
    output reg [15:0] product
);
    integer i;
    reg [15:0] multiplicand;
    reg [7:0] multiplier;
    
    always @(*) begin
        product = 16'b0;
        multiplicand = {8'b0, A};
        multiplier = B;
        for (i = 0; i < 8; i = i + 1) begin
            if (multiplier[0])
                product = product + multiplicand;
            multiplicand = multiplicand << 1;
            multiplier = multiplier >> 1;
        end
    end
endmodule