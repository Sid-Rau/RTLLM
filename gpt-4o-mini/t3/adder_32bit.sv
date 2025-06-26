module adder_32bit (
    input [31:0] A,
    input [31:0] B,
    output [31:0] S,
    output C32
);
    wire [15:0] P0, G0, C1;
    wire [15:0] P1, G1, C2;
    wire [15:0] P2, G2, C3;
    wire [15:0] P3, G3, C4;

    wire [15:0] S0, S1, S2, S3;

    // 16-bit CLA instances
    cla_16bit cla0 (
        .A(A[15:0]),
        .B(B[15:0]),
        .S(S[15:0]),
        .Cout(C1[0]),
        .P(P0),
        .G(G0)
    );

    cla_16bit cla1 (
        .A(A[31:16]),
        .B(B[31:16]),
        .S(S[31:16]),
        .Cout(C1[1]),
        .P(P1),
        .G(G1)
    );

    // Carry lookahead logic
    assign C1[0] = 0;
    assign C1[1] = G0[15] | (P0[15] & C1[0]);
    assign C32 = G1[15] | (P1[15] & C1[1]);

    // Sum calculation
    assign S[15:0] = A[15:0] ^ B[15:0] ^ C1[0];
    assign S[31:16] = A[31:16] ^ B[31:16] ^ C1[1];

endmodule

module cla_16bit (
    input [15:0] A,
    input [15:0] B,
    output [15:0] S,
    output Cout,
    output [15:0] P,
    output [15:0] G
);
    wire [15:0] C;

    assign P = A ^ B;
    assign G = A & B;

    assign C[0] = 0;
    genvar i;
    generate
        for (i = 0; i < 15; i = i + 1) begin : carry_gen
            assign C[i + 1] = G[i] | (P[i] & C[i]);
        end
    endgenerate

    assign S = P ^ C;
    assign Cout = C[15];

endmodule