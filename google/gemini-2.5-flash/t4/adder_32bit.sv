module cla_1bit(
    input  logic P_in,
    input  logic G_in,
    input  logic C_in,
    output logic S_out,
    output logic C_out
);

assign S_out = P_in ^ C_in;
assign C_out = G_in | (P_in & C_in);

endmodule

module cla_4bit(
    input  logic [3:0] P_in,
    input  logic [3:0] G_in,
    input  logic C_in,
    output logic [3:0] S_out,
    output logic        C_out
);

logic C0, C1, C2, C3;

assign C0 = C_in;
assign C1 = G_in[0] | (P_in[0] & C0);
assign C2 = G_in[1] | (P_in[1] & C1);
assign C3 = G_in[2] | (P_in[2] & C2);
assign C_out = G_in[3] | (P_in[3] & C3);

cla_1bit u0_cla_1bit (
    .P_in(P_in[0]),
    .G_in(G_in[0]),
    .C_in(C0),
    .S_out(S_out[0]),
    .C_out()
);

cla_1bit u1_cla_1bit (
    .P_in(P_in[1]),
    .G_in(G_in[1]),
    .C_in(C1),
    .S_out(S_out[1]),
    .C_out()
);

cla_1bit u2_cla_1bit (
    .P_in(P_in[2]),
    .G_in(G_in[2]),
    .C_in(C2),
    .S_out(S_out[2]),
    .C_out()
);

cla_1bit u3_cla_1bit (
    .P_in(P_in[3]),
    .G_in(G_in[3]),
    .C_in(C3),
    .S_out(S_out[3]),
    .C_out()
);

endmodule

module cla_16bit(
    input  logic [15:0] A_in,
    input  logic [15:0] B_in,
    input  logic        C_in,
    output logic [15:0] S_out,
    output logic        C_out
);

logic [15:0] P_local;
logic [15:0] G_local;

logic C4, C8, C12;

genvar i;
generate
    for (i = 0; i < 16; i++) begin : gen_PG
        assign P_local[i] = A_in[i] ^ B_in[i];
        assign G_local[i] = A_in[i] & B_in[i];
    end
endgenerate

cla_4bit u0_cla_4bit (
    .P_in(P_local[3:0]),
    .G_in(G_local[3:0]),
    .C_in(C_in),
    .S_out(S_out[3:0]),
    .C_out(C4)
);

cla_4bit u1_cla_4bit (
    .P_in(P_local[7:4]),
    .G_in(G_local[7:4]),
    .C_in(C4),
    .S_out(S_out[7:4]),
    .C_out(C8)
);

cla_4bit u2_cla_4bit (
    .P_in(P_local[11:8]),
    .G_in(G_local[11:8]),
    .C_in(C8),
    .S_out(S_out[11:8]),
    .C_out(C12)
);

cla_4bit u3_cla_4bit (
    .P_in(P_local[15:12]),
    .G_in(G_local[15:12]),
    .C_in(C12),
    .S_out(S_out[15:12]),
    .C_out(C_out)
);

endmodule

module adder_32bit(
    input  logic [32:1] A,
    input  logic [32:1] B,
    output logic [32:1] S,
    output logic        C32
);

logic C16;

cla_16bit u0_cla_16bit (
    .A_in(A[16:1]),
    .B_in(B[16:1]),
    .C_in(1'b0),
    .S_out(S[16:1]),
    .C_out(C16)
);

cla_16bit u1_cla_16bit (
    .A_in(A[32:17]),
    .B_in(B[32:17]),
    .C_in(C16),
    .S_out(S[32:17]),
    .C_out(C32)
);

endmodule