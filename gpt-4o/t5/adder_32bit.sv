module adder_32bit(
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);
    wire C16;

    cla_16bit cla1 (
        .A(A[16:1]),
        .B(B[16:1]),
        .Cin(1'b0),
        .S(S[16:1]),
        .Cout(C16)
    );

    cla_16bit cla2 (
        .A(A[32:17]),
        .B(B[32:17]),
        .Cin(C16),
        .S(S[32:17]),
        .Cout(C32)
    );

endmodule

module cla_16bit(
    input [16:1] A,
    input [16:1] B,
    input Cin,
    output [16:1] S,
    output Cout
);
    wire [16:0] P, G, C;

    assign P = {A[16:1] ^ B[16:1], 1'b0};
    assign G = {A[16:1] & B[16:1], Cin};
    assign C[0] = Cin;

    genvar i;
    generate
        for (i = 1; i <= 16; i = i + 1) begin : generate_carry
            assign C[i] = G[i] | (P[i] & C[i-1]);
        end
    endgenerate

    assign S = P[16:1] ^ C[15:0];
    assign Cout = C[16];

endmodule