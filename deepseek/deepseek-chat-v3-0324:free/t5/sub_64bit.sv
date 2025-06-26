module sub_64bit (
    input [63:0] A,
    input [63:0] B,
    output [63:0] result,
    output overflow
);

    wire [63:0] B_comp = ~B + 64'b1;
    wire [64:0] sum = {1'b0, A} + {1'b0, B_comp};
    assign result = sum[63:0];

    wire A_sign = A[63];
    wire B_sign = B[63];
    wire result_sign = result[63];

    assign overflow = (A_sign & ~B_sign & ~result_sign) | (~A_sign & B_sign & result_sign);

endmodule