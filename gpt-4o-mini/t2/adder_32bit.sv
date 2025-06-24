module adder_32bit (
    input  [31:0] A,
    input  [31:0] B,
    output [31:0] S,
    output C32
);
    wire [3:0] P, G, C;

    // 16-bit CLA block
    module cla_16bit (
        input  [15:0] A,
        input  [15:0] B,
        input  Cin,
        output [15:0] S,
        output Cout
    );
        wire [15:0] P, G;
        wire [3:0] C;

        assign P = A ^ B;
        assign G = A & B;

        assign C[0] = Cin;
        assign C[1] = G[0] | (P[0] & C[0]);
        assign C[2] = G[1] | (P[1] & C[1]);
        assign C[3] = G[2] | (P[2] & C[2]);
        assign Cout = G[3] | (P[3] & C[3]);

        assign S = P ^ {C[14:0], Cin};
    endmodule

    // Instance of 16-bit CLA blocks
    wire [15:0] S0, S1;
    wire C0, C1;

    cla_16bit cla0 (
        .A(A[15:0]),
        .B(B[15:0]),
        .Cin(1'b0),
        .S(S0),
        .Cout(C0)
    );

    cla_16bit cla1 (
        .A(A[31:16]),
        .B(B[31:16]),
        .Cin(C0),
        .S(S1),
        .Cout(C1)
    );

    assign S = {S1, S0};
    assign C32 = C1;

endmodule