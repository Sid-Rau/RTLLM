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

logic C_internal[3:0];

assign C_internal[0] = C_in;
assign C_internal[1] = G_in[0] | (P_in[0] & C_internal[0]);
assign C_internal[2] = G_in[1] | (P_in[1] & C_internal[1]);
assign C_internal[3] = G_in[2] | (P_in[2] & C_internal[2]);

assign S_out[0] = P_in[0] ^ C_internal[0];
assign S_out[1] = P_in[1] ^ C_internal[1];
assign S_out[2] = P_in[2] ^ C_internal[2];
assign S_out[3] = P_in[3] ^ C_internal[3];

assign C_out = G_in[3] | (P_in[3] & C_internal[3]);

endmodule

module cla_16bit(
    input  logic [15:0] P_in,
    input  logic [15:0] G_in,
    input  logic        C_in,
    output logic [15:0] S_out,
    output logic        C_out
);

logic P_group[3:0];
logic G_group[3:0];
logic C_internal[3:0];

cla_4bit cla_block_0 (
    .P_in  (P_in[3:0]),
    .G_in  (G_in[3:0]),
    .C_in  (C_in),
    .S_out (S_out[3:0]),
    .C_out (C_internal[0])
);

cla_4bit cla_block_1 (
    .P_in  (P_in[7:4]),
    .G_in  (G_in[7:4]),
    .C_in  (C_internal[0]),
    .S_out (S_out[7:4]),
    .C_out (C_internal[1])
);

cla_4bit cla_block_2 (
    .P_in  (P_in[11:8]),
    .G_in  (G_in[11:8]),
    .C_in  (C_internal[1]),
    .S_out (S_out[11:8]),
    .C_out (C_internal[2])
);

cla_4bit cla_block_3 (
    .P_in  (P_in[15:12]),
    .G_in  (G_in[15:12]),
    .C_in  (C_internal[2]),
    .S_out (S_out[15:12]),
    .C_out (C_internal[3])
);

assign C_out = C_internal[3];

endmodule

module adder_32bit(
    input  logic [32:1] A,
    input  logic [32:1] B,
    output logic [32:1] S,
    output logic        C32
);

logic [31:0] P_local;
logic [31:0] G_local;
logic        C_in_block[1:0];

genvar i;
for (i = 0; i < 32; i++) begin : gen_pg
    assign P_local[i] = A[i+1] ^ B[i+1];
    assign G_local[i] = A[i+1] & B[i+1];
end

cla_16bit cla_block_0 (
    .P_in  (P_local[15:0]),
    .G_in  (G_local[15:0]),
    .C_in  (1'b0), // C0 is always 0 for the first block
    .S_out (S[16:1]),
    .C_out (C_in_block[0])
);

cla_16bit cla_block_1 (
    .P_in  (P_local[31:16]),
    .G_in  (G_local[31:16]),
    .C_in  (C_in_block[0]),
    .S_out (S[32:17]),
    .C_out (C_in_block[1])
);

assign C32 = C_in_block[1];

endmodule