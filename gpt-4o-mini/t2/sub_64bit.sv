module sub_64bit(
    input  [63:0] A,
    input  [63:0] B,
    output [63:0] result,
    output overflow
);
    wire [63:0] sub_result;
    assign sub_result = A - B;
    assign result = sub_result;
    assign overflow = (A[63] ~^ B[63]) & (A[63] ^ sub_result[63]);
endmodule