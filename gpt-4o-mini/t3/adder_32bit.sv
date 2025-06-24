module adder_32bit (
    input [31:0] A,
    input [31:0] B,
    output [31:0] S,
    output C32
);
    wire [15:0] P, G, C;

    // 16-bit Carry Lookahead Adder
    module cla_16bit (
        input [15:0] A,
        input [15:0] B,
        output [15:0] S,
        output C
    );
        wire [15:0] P, G;
        wire [3:0] C_internal;

        assign P = A ^ B; // Propagate
        assign G = A & B; // Generate

        assign C_internal[0] = G[0] | (P[0] & 0);
        assign C_internal[1] = G[1] | (P[1] & C_internal[0]);
        assign C_internal[2] = G[2] | (P[2] & C_internal[1]);
        assign C_internal[3] = G[3] | (P[3] & C_internal[2]);

        assign C = G[3] | (P[3] & C_internal[2]);
        assign S = P ^ {C_internal[0], C_internal[0], C_internal[1], C_internal[1], C_internal[2], C_internal[2], C_internal[3], C_internal[3], 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
    endmodule

    wire C0, C1;

    cla_16bit CLA0 (
        .A(A[15:0]),
        .B(B[15:0]),
        .S(S[15:0]),
        .C(C0)
    );

    cla_16bit CLA1 (
        .A(A[31:16]),
        .B(B[31:16]),
        .S(S[31:16]),
        .C(C1)
    );

    assign C32 = C1 | (C0 & (A[15:0] | B[15:0]));

endmodule