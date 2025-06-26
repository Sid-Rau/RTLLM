module sub_64bit (
    input [63:0] A,
    input [63:0] B,
    output [63:0] result,
    output overflow
);
    wire [63:0] B_neg = ~B + 1'b1;
    wire [63:0] sum = A + B_neg;
    assign result = sum;

    wire A_sign = A[63];
    wire B_sign = B[63];
    wire sum_sign = sum[63];

    assign overflow = (~A_sign & B_sign & sum_sign) | (A_sign & ~B_sign & ~sum_sign);
endmodule