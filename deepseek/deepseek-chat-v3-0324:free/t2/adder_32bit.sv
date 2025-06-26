module adder_32bit(A, B, S, C32);
    input [32:1] A, B;
    output [32:1] S;
    output C32;

    wire [16:1] S1, S2;
    wire C16;

    cla_16bit cla1(.A(A[16:1]), .B(B[16:1]), .Cin(1'b0), .S(S1), .Cout(C16));
    cla_16bit cla2(.A(A[32:17]), .B(B[32:17]), .Cin(C16), .S(S2), .Cout(C32));

    assign S = {S2, S1};
endmodule

module cla_16bit(A, B, Cin, S, Cout);
    input [16:1] A, B;
    input Cin;
    output [16:1] S;
    output Cout;

    wire [4:1] G, P;
    wire [3:0] C;

    cla_4bit cla1(.A(A[4:1]), .B(B[4:1]), .Cin(Cin), .S(S[4:1]), .G(G[1]), .P(P[1]));
    cla_4bit cla2(.A(A[8:5]), .B(B[8:5]), .Cin(C[0]), .S(S[8:5]), .G(G[2]), .P(P[2]));
    cla_4bit cla3(.A(A[12:9]), .B(B[12:9]), .Cin(C[1]), .S(S[12:9]), .G(G[3]), .P(P[3]));
    cla_4bit cla4(.A(A[16:13]), .B(B[16:13]), .Cin(C[2]), .S(S[16:13]), .G(G[4]), .P(P[4]));

    carry_lookahead_unit clu(.G(G), .P(P), .Cin(Cin), .C({Cout, C}));
endmodule

module cla_4bit(A, B, Cin, S, G, P);
    input [4:1] A, B;
    input Cin;
    output [4:1] S;
    output G, P;

    wire [4:1] G_bit, P_bit;
    wire [3:1] C;

    assign G_bit = A & B;
    assign P_bit = A ^ B;
    assign G = G_bit[4] | (P_bit[4] & G_bit[3]) | (P_bit[4] & P_bit[3] & G_bit[2]) | (P_bit[4] & P_bit[3] & P_bit[2] & G_bit[1]);
    assign P = P_bit[4] & P_bit[3] & P_bit[2] & P_bit[1];

    assign C[1] = G_bit[1] | (P_bit[1] & Cin);
    assign C[2] = G_bit[2] | (P_bit[2] & G_bit[1]) | (P_bit[2] & P_bit[1] & Cin);
    assign C[3] = G_bit[3] | (P_bit[3] & G_bit[2]) | (P_bit[3] & P_bit[2] & G_bit[1]) | (P_bit[3] & P_bit[2] & P_bit[1] & Cin);

    assign S[1] = P_bit[1] ^ Cin;
    assign S[2] = P_bit[2] ^ C[1];
    assign S[3] = P_bit[3] ^ C[2];
    assign S[4] = P_bit[4] ^ C[3];
endmodule

module carry_lookahead_unit(G, P, Cin, C);
    input [4:1] G, P;
    input Cin;
    output [4:0] C;

    assign C[0] = G[1] | (P[1] & Cin);
    assign C[1] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & Cin);
    assign C[2] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & Cin);
    assign C[3] = G[4] | (P[4] & G[3]) | (P[4] & P[3] & G[2]) | (P[4] & P[3] & P[2] & G[1]) | (P[4] & P[3] & P[2] & P[1] & Cin);
    assign C[4] = C[3];
endmodule