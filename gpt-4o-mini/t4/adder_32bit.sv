module adder_32bit (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] S,
    output C32
);
    wire [15:0] P1, G1, C1;
    wire [15:0] P2, G2, C2;
    wire [15:0] P3, G3, C3;

    // 16-bit CLA instances
    cla_16bit CLA0 (
        .A(A[15:0]),
        .B(B[15:0]),
        .S(S[15:0]),
        .Cout(C1[0]),
        .P(P1),
        .G(G1)
    );

    cla_16bit CLA1 (
        .A(A[31:16]),
        .B(B[31:16]),
        .Cin(C1[0]),
        .S(S[31:16]),
        .Cout(C32),
        .P(P2),
        .G(G2)
    );

    // Carry generation
    assign C1[1] = G1[0] | (P1[0] & C1[0]);
    assign C1[2] = G1[1] | (P1[1] & C1[1]);
    assign C1[3] = G1[2] | (P1[2] & C1[2]);
    assign C1[4] = G1[3] | (P1[3] & C1[3]);
    assign C1[5] = G1[4] | (P1[4] & C1[4]);
    assign C1[6] = G1[5] | (P1[5] & C1[5]);
    assign C1[7] = G1[6] | (P1[6] & C1[6]);
    assign C1[8] = G1[7] | (P1[7] & C1[7]);
    assign C1[9] = G1[8] | (P1[8] & C1[8]);
    assign C1[10] = G1[9] | (P1[9] & C1[9]);
    assign C1[11] = G1[10] | (P1[10] & C1[10]);
    assign C1[12] = G1[11] | (P1[11] & C1[11]);
    assign C1[13] = G1[12] | (P1[12] & C1[12]);
    assign C1[14] = G1[13] | (P1[13] & C1[13]);
    assign C1[15] = G1[14] | (P1[14] & C1[14]);
    
endmodule

module cla_16bit (
    input  [15:0] A,
    input  [15:0] B,
    input  Cin,
    output [15:0] S,
    output Cout,
    output [15:0] P,
    output [15:0] G
);
    wire [15:0] C;

    assign P = A ^ B;
    assign G = A & B;

    assign C[0] = Cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C[3] = G[2] | (P[2] & C[2]);
    assign C[4] = G[3] | (P[3] & C[3]);
    assign C[5] = G[4] | (P[4] & C[4]);
    assign C[6] = G[5] | (P[5] & C[5]);
    assign C[7] = G[6] | (P[6] & C[6]);
    assign C[8] = G[7] | (P[7] & C[7]);
    assign C[9] = G[8] | (P[8] & C[8]);
    assign C[10] = G[9] | (P[9] & C[9]);
    assign C[11] = G[10] | (P[10] & C[10]);
    assign C[12] = G[11] | (P[11] & C[11]);
    assign C[13] = G[12] | (P[12] & C[12]);
    assign C[14] = G[13] | (P[13] & C[13]);
    assign C[15] = G[14] | (P[14] & C[14]);
    assign Cout = G[15] | (P[15] & C[15]);

    assign S = P ^ C;

endmodule