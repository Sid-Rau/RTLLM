module sub_64bit (
    input [63:0] A,
    input [63:0] B,
    output [63:0] result,
    output overflow
);

    wire [63:0] B_neg = ~B + 1'b1;
    wire [64:0] sum = {A[63], A} + {B_neg[63], B_neg};
    assign result = sum[63:0];
    assign overflow = (~A[63] & B[63] & result[63]) | (A[63] & ~B[63] & ~result[63]);

endmodule