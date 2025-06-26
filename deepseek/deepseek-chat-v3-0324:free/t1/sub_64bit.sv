module sub_64bit (
    input [63:0] A,
    input [63:0] B,
    output [63:0] result,
    output overflow
);

    wire [63:0] B_comp = ~B + 64'b1;
    wire [64:0] sum = {A[63], A} + {B_comp[63], B_comp};
    assign result = sum[63:0];
    assign overflow = (A[63] == B_comp[63]) && (result[63] != A[63]);

endmodule