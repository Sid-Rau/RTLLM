module adder_32bit(A, B, S, C32);
    input [32:1] A, B;
    output [32:1] S;
    output C32;

    wire [16:1] S_low, S_high;
    wire C16;

    adder_16bit low_adder(
        .A(A[16:1]),
        .B(B[16:1]),
        .Cin(1'b0),
        .S(S_low),
        .Cout(C16)
    );

    adder_16bit high_adder(
        .A(A[32:17]),
        .B(B[32:17]),
        .Cin(C16),
        .S(S_high),
        .Cout(C32)
    );

    assign S = {S_high, S_low};
endmodule

module adder_16bit(A, B, Cin, S, Cout);
    input [16:1] A, B;
    input Cin;
    output [16:1] S;
    output Cout;

    wire [4:1] G, P, C;

    assign C[1] = Cin;
    assign Cout = C[5];

    genvar i;
    generate
        for (i = 1; i <= 4; i = i + 1) begin : cla_slice
            wire [3:0] G_slice, P_slice;
            wire [4:0] C_slice;

            adder_4bit adder(
                .A(A[i*4:(i-1)*4+1]),
                .B(B[i*4:(i-1)*4+1]),
                .Cin(C[i]),
                .S(S[i*4:(i-1)*4+1]),
                .G(G_slice),
                .P(P_slice)
            );

            assign G[i] = G_slice[3];
            assign P[i] = &P_slice;
            assign C[i+1] = G[i] | (P[i] & C[i]);
        end
    endgenerate
endmodule

module adder_4bit(A, B, Cin, S, G, P);
    input [4:1] A, B;
    input Cin;
    output [4:1] S;
    output [3:0] G, P;

    wire [4:0] C;
    assign C[1] = Cin;

    genvar i;
    generate
        for (i = 1; i <= 4; i = i + 1) begin : bit_slice
            assign G[i-1] = A[i] & B[i];
            assign P[i-1] = A[i] | B[i];
            assign S[i] = A[i] ^ B[i] ^ C[i];
            assign C[i+1] = G[i-1] | (P[i-1] & C[i]);
        end
    endgenerate
endmodule