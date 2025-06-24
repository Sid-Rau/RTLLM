module adder_32bit (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] S,
    output C32
);
    wire [3:0] P, G, C;
    
    // 16-bit CLA instances
    CLA_16bit cla0 (
        .A(A[15:0]),
        .B(B[15:0]),
        .C_in(1'b0),
        .S(S[15:0]),
        .P(P[0]),
        .G(G[0]),
        .C_out(C[0])
    );
    
    CLA_16bit cla1 (
        .A(A[31:16]),
        .B(B[31:16]),
        .C_in(C[0]),
        .S(S[31:16]),
        .P(P[1]),
        .G(G[1]),
        .C_out(C[1])
    );
    
    assign C32 = C[1];
    
endmodule

module CLA_16bit (
    input  [15:0] A,
    input  [15:0] B,
    input  C_in,
    output [15:0] S,
    output P,
    output G,
    output C_out
);
    wire [15:0] P_temp, G_temp, C;
    
    assign P_temp = A ^ B;
    assign G_temp = A & B;
    
    assign P = |P_temp;
    assign G = |G_temp;
    
    assign C[0] = G_temp[0] | (P_temp[0] & C_in);
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : carry_gen
            assign C[i] = G_temp[i] | (P_temp[i] & C[i-1]);
        end
    endgenerate
    
    assign S = P_temp ^ {C[14:0], C_in};
    assign C_out = C[15];
    
endmodule