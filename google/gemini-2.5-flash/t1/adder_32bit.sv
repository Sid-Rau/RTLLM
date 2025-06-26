module cla_1bit(
    input  logic A,
    input  logic B,
    input  logic Cin,
    output logic S,
    output logic G,
    output logic P
);

assign P = A ^ B;
assign G = A & B;
assign S = A ^ B ^ Cin;

endmodule

module cla_4bit(
    input  logic [3:0] A,
    input  logic [3:0] B,
    input  logic Cin,
    output logic [3:0] S,
    output logic Cout,
    output logic G_out,
    output logic P_out
);

logic [3:0] P;
logic [3:0] G;
logic [3:0] C;

cla_1bit u0_cla_1bit (
    .A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .G(G[0]), .P(P[0])
);
cla_1bit u1_cla_1bit (
    .A(A[1]), .B(B[1]), .Cin(C[0]), .S(S[1]), .G(G[1]), .P(P[1])
);
cla_1bit u2_cla_1bit (
    .A(A[2]), .B(B[2]), .Cin(C[1]), .S(S[2]), .G(G[2]), .P(P[2])
);
cla_1bit u3_cla_1bit (
    .A(A[3]), .B(B[3]), .Cin(C[2]), .S(S[3]), .G(G[3]), .P(P[3])
);

assign C[0] = G[0] | (P[0] & Cin);
assign C[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
assign C[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin);
assign Cout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & Cin);

assign P_out = P[3] & P[2] & P[1] & P[0];
assign G_out = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);

endmodule

module cla_16bit(
    input  logic [15:0] A,
    input  logic [15:0] B,
    input  logic Cin,
    output logic [15:0] S,
    output logic Cout,
    output logic G_out,
    output logic P_out
);

logic [3:0] P_group;
logic [3:0] G_group;
logic [3:0] C_group;

cla_4bit u0_cla_4bit (
    .A(A[3:0]),   .B(B[3:0]),   .Cin(Cin),    .S(S[3:0]),
    .Cout(), .G_out(G_group[0]), .P_out(P_group[0])
);
cla_4bit u1_cla_4bit (
    .A(A[7:4]),   .B(B[7:4]),   .Cin(C_group[0]), .S(S[7:4]),
    .Cout(), .G_out(G_group[1]), .P_out(P_group[1])
);
cla_4bit u2_cla_4bit (
    .A(A[11:8]),  .B(B[11:8]),  .Cin(C_group[1]), .S(S[11:8]),
    .Cout(), .G_out(G_group[2]), .P_out(P_group[2])
);
cla_4bit u3_cla_4bit (
    .A(A[15:12]), .B(B[15:12]), .Cin(C_group[2]), .S(S[15:12]),
    .Cout(), .G_out(G_group[3]), .P_out(P_group[3])
);

assign C_group[0] = G_group[0] | (P_group[0] & Cin);
assign C_group[1] = G_group[1] | (P_group[1] & G_group[0]) | (P_group[1] & P_group[0] & Cin);
assign C_group[2] = G_group[2] | (P_group[2] & G_group[1]) | (P_group[2] & P_group[1] & G_group[0]) | (P_group[2] & P_group[1] & P_group[0] & Cin);
assign Cout = G_group[3] | (P_group[3] & G_group[2]) | (P_group[3] & P_group[2] & G_group[1]) | (P_group[3] & P_group[2] & P_group[1] & G_group[0]) | (P_group[3] & P_group[2] & P_group[1] & P_group[0] & Cin);

assign P_out = P_group[3] & P_group[2] & P_group[1] & P_group[0];
assign G_out = G_group[3] | (P_group[3] & G_group[2]) | (P_group[3] & P_group[2] & G_group[1]) | (P_group[3] & P_group[2] & P_group[1] & G_group[0]);

endmodule

module adder_32bit(
    input  logic [32:1] A,
    input  logic [32:1] B,
    output logic [32:1] S,
    output logic C32
);

logic C16;
logic G_group_0, P_group_0;
logic G_group_1, P_group_1;

cla_16bit u0_cla_16bit (
    .A(A[16:1]), .B(B[16:1]), .Cin(1'b0), .S(S[16:1]),
    .Cout(), .G_out(G_group_0), .P_out(P_group_0)
);

cla_16bit u1_cla_16bit (
    .A(A[32:17]), .B(B[32:17]), .Cin(C16), .S(S[32:17]),
    .Cout(), .G_out(G_group_1), .P_out(P_group_1)
);

assign C16 = G_group_0 | (P_group_0 & 1'b0); // Cin for first 16-bit block is 0
assign C32 = G_group_1 | (P_group_1 & C16);

endmodule