module adder_32bit (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] S,
    output C32
);

    wire [15:0] P0, G0, C1;
    wire [15:0] P1, G1, C2;
    wire [15:0] P2, G2, C3;

    // 16-bit CLA instances
    cla_16bit cla0 (
        .A(A[15:0]),
        .B(B[15:0]),
        .P(P0),
        .G(G0),
        .C_in(1'b0),
        .S(S[15:0]),
        .C_out(C1[0])
    );

    cla_16bit cla1 (
        .A(A[31:16]),
        .B(B[31:16]),
        .P(P1),
        .G(G1),
        .C_in(C1[0]),
        .S(S[31:16]),
        .C_out(C1[1])
    );

    // Carry Lookahead Logic
    assign C2[0] = G0[0] | (P0[0] & 1'b0);
    assign C2[1] = G0[1] | (P0[1] & C2[0]);
    assign C2[2] = G0[2] | (P0[2] & C2[1]);
    assign C2[3] = G0[3] | (P0[3] & C2[2]);
    assign C2[4] = G0[4] | (P0[4] & C2[3]);
    assign C2[5] = G0[5] | (P0[5] & C2[4]);
    assign C2[6] = G0[6] | (P0[6] & C2[5]);
    assign C2[7] = G0[7] | (P0[7] & C2[6]);
    assign C2[8] = G0[8] | (P0[8] & C2[7]);
    assign C2[9] = G0[9] | (P0[9] & C2[8]);
    assign C2[10] = G0[10] | (P0[10] & C2[9]);
    assign C2[11] = G0[11] | (P0[11] & C2[10]);
    assign C2[12] = G0[12] | (P0[12] & C2[11]);
    assign C2[13] = G0[13] | (P0[13] & C2[12]);
    assign C2[14] = G0[14] | (P0[14] & C2[13]);
    assign C2[15] = G0[15] | (P0[15] & C2[14]);

    assign C32 = G1[0] | (P1[0] & C2[15]);

endmodule

module cla_16bit (
    input  [15:0] A,
    input  [15:0] B,
    output [15:0] P,
    output [15:0] G,
    input  C_in,
    output [15:0] S,
    output C_out
);

    assign P = A ^ B;
    assign G = A & B;
    assign S = P ^ {C_in, C_in, C_in, C_in, C_in, C_in, C_in, C_in, C_in, C_in, C_in, C_in, C_in, C_in, C_in, C_in};
    assign C_out = G | (P & C_in);

endmodule