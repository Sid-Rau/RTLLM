module adder_32bit(A, B, S, C32);
    input [32:1] A;
    input [32:1] B;
    output [32:1] S;
    output C32;

    wire [16:1] S_low, S_high;
    wire C16;

    adder_16bit low_adder (
        .A(A[16:1]),
        .B(B[16:1]),
        .Cin(1'b0),
        .S(S_low),
        .Cout(C16)
    );

    adder_16bit high_adder (
        .A(A[32:17]),
        .B(B[32:17]),
        .Cin(C16),
        .S(S_high),
        .Cout(C32)
    );

    assign S = {S_high, S_low};
endmodule

module adder_16bit(A, B, Cin, S, Cout);
    input [16:1] A;
    input [16:1] B;
    input Cin;
    output [16:1] S;
    output Cout;

    wire [4:1] G, P;
    wire [4:1] C;

    adder_4bit adder0 (
        .A(A[4:1]),
        .B(B[4:1]),
        .Cin(Cin),
        .S(S[4:1]),
        .G(G[1]),
        .P(P[1])
    );

    adder_4bit adder1 (
        .A(A[8:5]),
        .B(B[8:5]),
        .Cin(C[1]),
        .S(S[8:5]),
        .G(G[2]),
        .P(P[2])
    );

    adder_4bit adder2 (
        .A(A[12:9]),
        .B(B[12:9]),
        .Cin(C[2]),
        .S(S[12:9]),
        .G(G[3]),
        .P(P[3])
    );

    adder_4bit adder3 (
        .A(A[16:13]),
        .B(B[16:13]),
        .Cin(C[3]),
        .S(S[16:13]),
        .G(G[4]),
        .P(P[4])
    );

    cla_logic cla (
        .G(G),
        .P(P),
        .Cin(Cin),
        .C({Cout, C[3:1]})
    );
endmodule

module adder_4bit(A, B, Cin, S, G, P);
    input [4:1] A;
    input [4:1] B;
    input Cin;
    output [4:1] S;
    output G;
    output P;

    wire [4:1] G_i;
    wire [4:1] P_i;
    wire [4:1] C;

    assign G_i = A & B;
    assign P_i = A ^ B;
    assign S = P_i ^ {C[3:1], Cin};

    assign G = G_i[4] | (P_i[4] & G_i[3]) | (P_i[4] & P_i[3] & G_i[2]) | (P_i[4] & P_i[3] & P_i[2] & G_i[1]);
    assign P = P_i[4] & P_i[3] & P_i[2] & P_i[1];

    assign C[1] = G_i[1] | (P_i[1] & Cin);
    assign C[2] = G_i[2] | (P_i[2] & G_i[1]) | (P_i[2] & P_i[1] & Cin);
    assign C[3] = G_i[3] | (P_i[3] & G_i[2]) | (P_i[3] & P_i[2] & G_i[1]) | (P_i[3] & P_i[2] & P_i[1] & Cin);
    assign C[4] = G_i[4] | (P_i[4] & G_i[3]) | (P_i[4] & P_i[3] & G_i[2]) | (P_i[4] & P_i[3] & P_i[2] & G_i[1]) | (P_i[4] & P_i[3] & P_i[2] & P_i[1] & Cin);
endmodule

module cla_logic(G, P, Cin, C);
    input [4:1] G;
    input [4:1] P;
    input Cin;
    output [4:1] C;

    assign C[1] = G[1] | (P[1] & Cin);
    assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & Cin);
    assign C[3] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & Cin);
    assign C[4] = G[4] | (P[4] & G[3]) | (P[4] & P[3] & G[2]) | (P[4] & P[3] & P[2] & G[1]) | (P[4] & P[3] & P[2] & P[1] & Cin);
endmodule