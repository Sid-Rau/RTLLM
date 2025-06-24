module adder_32bit (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] S,
    output C32
);
    wire [3:0] P, G, C;

    wire [15:0] S0, S1, S2, S3;
    wire C0, C1, C2, C3;

    // 16-bit CLA instance 0
    cla_16bit cla0 (
        .A(A[15:0]),
        .B(B[15:0]),
        .S(S0),
        .Cout(C0),
        .P(P[0]),
        .G(G[0])
    );

    // 16-bit CLA instance 1
    cla_16bit cla1 (
        .A(A[31:16]),
        .B(B[31:16]),
        .S(S1),
        .Cout(C1),
        .P(P[1]),
        .G(G[1])
    );

    // Generate carry signals for the higher 16 bits
    assign C[0] = 1'b0;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C32 = G[1] | (P[1] & C[2]);

    // Combine results
    assign S = {S1, S0};

endmodule

module cla_16bit (
    input  [15:0] A,
    input  [15:0] B,
    output [15:0] S,
    output Cout,
    output P,
    output G
);
    wire [15:0] P_int, G_int, C;

    assign P_int = A ^ B;
    assign G_int = A & B;

    assign C[0] = 1'b0;
    assign C[1] = G_int[0] | (P_int[0] & C[0]);
    assign C[2] = G_int[1] | (P_int[1] & C[1]);
    assign C[3] = G_int[2] | (P_int[2] & C[2]);
    assign C[4] = G_int[3] | (P_int[3] & C[3]);
    assign C[5] = G_int[4] | (P_int[4] & C[4]);
    assign C[6] = G_int[5] | (P_int[5] & C[5]);
    assign C[7] = G_int[6] | (P_int[6] & C[6]);
    assign C[8] = G_int[7] | (P_int[7] & C[7]);
    assign C[9] = G_int[8] | (P_int[8] & C[8]);
    assign C[10] = G_int[9] | (P_int[9] & C[9]);
    assign C[11] = G_int[10] | (P_int[10] & C[10]);
    assign C[12] = G_int[11] | (P_int[11] & C[11]);
    assign C[13] = G_int[12] | (P_int[12] & C[12]);
    assign C[14] = G_int[13] | (P_int[13] & C[13]);
    assign C[15] = G_int[14] | (P_int[14] & C[14]);
    assign Cout = G_int[15] | (P_int[15] & C[15]);

    assign S = P_int ^ C;

endmodule