module cla_4bit (
    input [3:0] P_in,
    input [3:0] G_in,
    input C_in,
    output [3:0] C_out,
    output P_out,
    output G_out
);

    wire C0, C1, C2, C3;

    assign C0 = C_in;
    assign C1 = G_in[0] | (P_in[0] & C0);
    assign C2 = G_in[1] | (P_in[1] & G_in[0]) | (P_in[1] & P_in[0] & C0);
    assign C3 = G_in[2] | (P_in[2] & G_in[1]) | (P_in[2] & P_in[1] & G_in[0]) | (P_in[2] & P_in[1] & P_in[0] & C0);

    assign C_out[0] = C1;
    assign C_out[1] = C2;
    assign C_out[2] = C3;
    assign C_out[3] = G_in[3] | (P_in[3] & G_in[2]) | (P_in[3] & P_in[2] & G_in[1]) | (P_in[3] & P_in[2] & P_in[1] & G_in[0]) | (P_in[3] & P_in[2] & P_in[1] & P_in[0] & C0);

    assign P_out = P_in[3] & P_in[2] & P_in[1] & P_in[0];
    assign G_out = G_in[3] | (P_in[3] & G_in[2]) | (P_in[3] & P_in[2] & G_in[1]) | (P_in[3] & P_in[2] & P_in[1] & G_in[0]);

endmodule

module cla_16bit (
    input [15:0] A,
    input [15:0] B,
    input C_in,
    output [15:0] S,
    output C_out,
    output P_out,
    output G_out
);

    wire [15:0] P_local;
    wire [15:0] G_local;
    wire [3:0] P_group;
    wire [3:0] G_group;
    wire [3:0] C_inter;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : bit_pg
            assign P_local[i] = A[i] ^ B[i];
            assign G_local[i] = A[i] & B[i];
        end
    endgenerate

    cla_4bit cla0 (
        .P_in(P_local[3:0]),
        .G_in(G_local[3:0]),
        .C_in(C_in),
        .C_out(C_inter[0]),
        .P_out(P_group[0]),
        .G_out(G_group[0])
    );

    cla_4bit cla1 (
        .P_in(P_local[7:4]),
        .G_in(G_local[7:4]),
        .C_in(C_inter[0]),
        .C_out(C_inter[1]),
        .P_out(P_group[1]),
        .G_out(G_group[1])
    );

    cla_4bit cla2 (
        .P_in(P_local[11:8]),
        .G_in(G_local[11:8]),
        .C_in(C_inter[1]),
        .C_out(C_inter[2]),
        .P_out(P_group[2]),
        .G_out(G_group[2])
    );

    cla_4bit cla3 (
        .P_in(P_local[15:12]),
        .G_in(G_local[15:12]),
        .C_in(C_inter[2]),
        .C_out(C_inter[3]),
        .P_out(P_group[3]),
        .G_out(G_group[3])
    );

    cla_4bit cla_top (
        .P_in(P_group),
        .G_in(G_group),
        .C_in(C_in),
        .C_out(C_out), // This C_out is the final carry-out of the 16-bit block
        .P_out(P_out),
        .G_out(G_out)
    );

    // Sum bits calculation
    assign S[0] = P_local[0] ^ C_in;
    assign S[1] = P_local[1] ^ C_inter[0][0];
    assign S[2] = P_local[2] ^ C_inter[0][1];
    assign S[3] = P_local[3] ^ C_inter[0][2];

    assign S[4] = P_local[4] ^ C_inter[0][3];
    assign S[5] = P_local[5] ^ C_inter[1][0];
    assign S[6] = P_local[6] ^ C_inter[1][1];
    assign S[7] = P_local[7] ^ C_inter[1][2];

    assign S[8] = P_local[8] ^ C_inter[1][3];
    assign S[9] = P_local[9] ^ C_inter[2][0];
    assign S[10] = P_local[10] ^ C_inter[2][1];
    assign S[11] = P_local[11] ^ C_inter[2][2];

    assign S[12] = P_local[12] ^ C_inter[2][3];
    assign S[13] = P_local[13] ^ C_inter[3][0];
    assign S[14] = P_local[14] ^ C_inter[3][1];
    assign S[15] = P_local[15] ^ C_inter[3][2];

endmodule

module adder_32bit (
    input [32:1] A,
    input [32:1] B,
    output [32:1] S,
    output C32
);

    wire C16;
    wire P_group0, G_group0;
    wire P_group1, G_group1;

    cla_16bit cla_low (
        .A(A[16:1]),
        .B(B[16:1]),
        .C_in(1'b0), // Initial carry-in for the LSB block is 0
        .S(S[16:1]),
        .C_out(C16),
        .P_out(P_group0),
        .G_out(G_group0)
    );

    cla_16bit cla_high (
        .A(A[32:17]),
        .B(B[32:17]),
        .C_in(C16), // Carry-in for the MSB block is carry-out of LSB block
        .S(S[32:17]),
        .C_out(C32), // Final carry-out of the 32-bit adder
        .P_out(P_group1),
        .G_out(G_group1)
    );

endmodule