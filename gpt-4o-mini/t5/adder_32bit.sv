module adder_32bit (
    input [31:0] A,
    input [31:0] B,
    output [31:0] S,
    output C32
);
    wire [15:0] G, P, C;

    // 16-bit CLA instances
    cla_16bit cla0 (
        .A(A[15:0]),
        .B(B[15:0]),
        .G(G[0]),
        .P(P[0]),
        .C_in(1'b0),
        .S(S[15:0]),
        .C_out(C[0])
    );

    cla_16bit cla1 (
        .A(A[31:16]),
        .B(B[31:16]),
        .G(G[1]),
        .P(P[1]),
        .C_in(C[0]),
        .S(S[31:16]),
        .C_out(C32)
    );

    // Generate and propagate logic
    assign G[0] = A[15:0] & B[15:0];
    assign P[0] = A[15:0] | B[15:0];
    assign G[1] = A[31:16] & B[31:16];
    assign P[1] = A[31:16] | B[31:16];

    // Carry logic
    assign C[1] = G[0] | (P[0] & 1'b0);
    
endmodule

module cla_16bit (
    input [15:0] A,
    input [15:0] B,
    output G,
    output P,
    input C_in,
    output [15:0] S,
    output C_out
);
    wire [15:0] G_temp, P_temp, C;

    assign G_temp = A & B;
    assign P_temp = A | B;

    assign C[0] = C_in;

    genvar i;
    generate
        for (i = 0; i < 15; i = i + 1) begin : carry_gen
            assign C[i + 1] = G_temp[i] | (P_temp[i] & C[i]);
        end
    endgenerate

    assign S = A ^ B ^ C;
    assign G = G_temp[15];
    assign P = P_temp[15];
    assign C_out = C[15];

endmodule