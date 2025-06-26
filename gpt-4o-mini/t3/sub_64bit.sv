module sub_64bit (
    input  [63:0] A,
    input  [63:0] B,
    output [63:0] result,
    output overflow
);
    wire [63:0] B_neg;
    wire [63:0] temp_result;
    assign B_neg = ~B + 1;
    assign temp_result = A + B_neg;
    assign result = temp_result;
    assign overflow = ((A[63] == 0 && B[63] == 1 && result[63] == 1) || 
                       (A[63] == 1 && B[63] == 0 && result[63] == 0));
endmodule