module adder_32bit (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] S,
    output C32
);
    wire [15:0] P, G, C;

    // Generate the carry signals for the first 16-bit CLA
    CLA_16bit cla0 (
        .A(A[15:0]),
        .B(B[15:0]),
        .S(S[15:0]),
        .Cout(C[0]),
        .P(P[0]),
        .G(G[0])
    );

    // Generate the carry signals for the second 16-bit CLA
    CLA_16bit cla1 (
        .A(A[31:16]),
        .B(B[31:16]),
        .S(S[31:16]),
        .Cout(C32),
        .P(P[1]),
        .G(G[1])
    );

    // Carry lookahead logic
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C32 = G[1] | (P[1] & C[1]);

endmodule

module CLA_16bit (
    input  [15:0] A,
    input  [15:0] B,
    output [15:0] S,
    output Cout,
    output P,
    output G
);
    wire [15:0] P_temp, G_temp, C;

    assign P_temp = A ^ B;
    assign G_temp = A & B;

    assign C[0] = 1'b0;
    genvar i;
    generate
        for (i = 0; i < 15; i = i + 1) begin : carry_gen
            assign C[i + 1] = G_temp[i] | (P_temp[i] & C[i]);
        end
    endgenerate

    assign S = P_temp ^ C;
    assign Cout = C[15];
    assign P = &P_temp;
    assign G = |G_temp;

endmodule