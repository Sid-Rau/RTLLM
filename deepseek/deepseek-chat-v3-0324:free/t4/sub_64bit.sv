module sub_64bit (
    input [63:0] A,
    input [63:0] B,
    output [63:0] result,
    output overflow
);

    wire [63:0] B_neg;
    wire [63:0] sum;
    wire carry_out;

    assign B_neg = ~B + 64'd1;
    assign {carry_out, sum} = A + B_neg;
    assign result = sum;

    wire sign_A = A[63];
    wire sign_B = B[63];
    wire sign_result = result[63];

    assign overflow = (~sign_A & sign_B & sign_result) | (sign_A & ~sign_B & ~sign_result);

endmodule