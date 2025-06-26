module adder_32bit(A, B, S, C32);
    input [32:1] A, B;
    output [32:1] S;
    output C32;

    wire [16:1] S1, S2;
    wire C16;

    adder_16bit adder1(.A(A[16:1]), .B(B[16:1]), .cin(1'b0), .S(S1), .cout(C16));
    adder_16bit adder2(.A(A[32:17]), .B(B[32:17]), .cin(C16), .S(S2), .cout(C32));

    assign S = {S2, S1};
endmodule

module adder_16bit(A, B, cin, S, cout);
    input [16:1] A, B;
    input cin;
    output [16:1] S;
    output cout;

    wire [4:1] G, P, C;

    assign C[1] = cin;
    assign cout = C[4];

    cla_block cla1(.A(A[4:1]), .B(B[4:1]), .cin(C[1]), .S(S[4:1]), .G(G[1]), .P(P[1]), .cout(C[2]));
    cla_block cla2(.A(A[8:5]), .B(B[8:5]), .cin(C[2]), .S(S[8:5]), .G(G[2]), .P(P[2]), .cout(C[3]));
    cla_block cla3(.A(A[12:9]), .B(B[12:9]), .cin(C[3]), .S(S[12:9]), .G(G[3]), .P(P[3]), .cout(C[4]));
    cla_block cla4(.A(A[16:13]), .B(B[16:13]), .cin(C[4]), .S(S[16:13]), .G(G[4]), .P(P[4]), .cout());
endmodule

module cla_block(A, B, cin, S, G, P, cout);
    input [4:1] A, B;
    input cin;
    output [4:1] S;
    output G, P;
    output cout;

    wire [4:1] g, p, c;

    assign g = A & B;
    assign p = A ^ B;
    assign c[1] = cin;
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & c[1]);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & c[1]);
    assign cout = g[4] | (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]) | (p[4] & p[3] & p[2] & p[1] & c[1]);

    assign G = g[4] | (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]);
    assign P = p[4] & p[3] & p[2] & p[1];
    assign S = p ^ c[4:1];
endmodule