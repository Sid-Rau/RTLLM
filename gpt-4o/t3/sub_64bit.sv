module sub_64bit(
    input [63:0] A,
    input [63:0] B,
    output [63:0] result,
    output overflow
);
    wire [63:0] B_neg;
    wire [63:0] sum;
    wire carry_out;

    assign B_neg = ~B + 1;
    assign {carry_out, sum} = A + B_neg;
    assign result = sum;

    assign overflow = ((A[63] & ~B[63] & ~sum[63]) | (~A[63] & B[63] & sum[63]));

endmodule