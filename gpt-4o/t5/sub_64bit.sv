module sub_64bit(
    input [63:0] A,
    input [63:0] B,
    output [63:0] result,
    output overflow
);
    wire [63:0] B_neg;
    wire [63:0] sum;
    wire A_sign, B_sign, sum_sign;
    
    assign B_neg = ~B + 1;
    assign sum = A + B_neg;
    assign result = sum;
    
    assign A_sign = A[63];
    assign B_sign = B[63];
    assign sum_sign = sum[63];
    
    assign overflow = (A_sign & ~B_sign & ~sum_sign) | (~A_sign & B_sign & sum_sign);
endmodule