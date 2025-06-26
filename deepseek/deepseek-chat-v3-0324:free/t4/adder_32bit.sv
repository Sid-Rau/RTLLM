module adder_32bit(A, B, S, C32);
    input [32:1] A, B;
    output [32:1] S;
    output C32;

    wire [16:1] S1, S2;
    wire C16;

    adder_16bit cla1(.A(A[16:1]), .B(B[16:1]), .Cin(1'b0), .S(S1), .Cout(C16));
    adder_16bit cla2(.A(A[32:17]), .B(B[32:17]), .Cin(C16), .S(S2), .Cout(C32));

    assign S = {S2, S1};
endmodule

module adder_16bit(A, B, Cin, S, Cout);
    input [16:1] A, B;
    input Cin;
    output [16:1] S;
    output Cout;

    wire [4:1] P, G;
    wire [3:0] C;

    adder_4bit cla_block1(.A(A[4:1]), .B(B[4:1]), .Cin(Cin), .S(S[4:1]), .P(P[1]), .G(G[1]));
    adder_4bit cla_block2(.A(A[8:5]), .B(B[8:5]), .Cin(C[0]), .S(S[8:5]), .P(P[2]), .G(G[2]));
    adder_4bit cla_block3(.A(A[12:9]), .B(B[12:9]), .Cin(C[1]), .S(S[12:9]), .P(P[3]), .G(G[3]));
    adder_4bit cla_block4(.A(A[16:13]), .B(B[16:13]), .Cin(C[2]), .S(S[16:13]), .P(P[4]), .G(G[4]));

    cla_logic cla(.P(P), .G(G), .Cin(Cin), .C({Cout, C[2:0]}));
endmodule

module adder_4bit(A, B, Cin, S, P, G);
    input [4:1] A, B;
    input Cin;
    output [4:1] S;
    output P, G;

    wire [4:1] P_i, G_i;
    wire [3:0] C;

    assign P_i[1] = A[1] ^ B[1];
    assign G_i[1] = A[1] & B[1];
    assign S[1] = P_i[1] ^ Cin;
    assign P_i[2] = A[2] ^ B[2];
    assign G_i[2] = A[2] & B[2];
    assign C[0] = G_i[1] | (P_i[1] & Cin);
    assign S[2] = P_i[2] ^ C[0];
    assign P_i[3] = A[3] ^ B[3];
    assign G_i[3] = A[3] & B[3];
    assign C[1] = G_i[2] | (P_i[2] & C[0]);
    assign S[3] = P_i[3] ^ C[1];
    assign P_i[4] = A[4] ^ B[4];
    assign G_i[4] = A[4] & B[4];
    assign C[2] = G_i[3] | (P_i[3] & C[1]);
    assign S[4] = P_i[4] ^ C[2];
    assign P = P_i[1] & P_i[2] & P_i[3] & P_i[4];
    assign G = G_i[4] | (P_i[4] & G_i[3]) | (P_i[4] & P_i[3] & G_i[2]) | (P_i[4] & P_i[3] & P_i[2] & G_i[1]);
endmodule

module cla_logic(P, G, Cin, C);
    input [4:1] P, G;
    input Cin;
    output [3:0] C;

    assign C[0] = G[1] | (P[1] & Cin);
    assign C[1] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & Cin);
    assign C[2] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & Cin);
    assign C[3] = G[4] | (P[4] & G[3]) | (P[4] & P[3] & G[2]) | (P[4] & P[3] & P[2] & G[1]) | (P[4] & P[3] & P[2] & P[1] & Cin);
endmodule