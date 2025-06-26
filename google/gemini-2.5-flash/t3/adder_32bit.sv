module cla_1bit (
  input  logic a,
  input  logic b,
  input  logic cin,
  output logic sum,
  output logic cout,
  output logic p,
  output logic g
);

  assign sum  = a ^ b ^ cin;
  assign cout = (a & b) | (cin & (a ^ b));
  assign p    = a ^ b;
  assign g    = a & b;

endmodule

module cla_4bit (
  input  logic [3:0] a,
  input  logic [3:0] b,
  input  logic       cin,
  output logic [3:0] s,
  output logic       cout,
  output logic       P,
  output logic       G
);

  logic [3:0] p_local;
  logic [3:0] g_local;
  logic [3:1] c_local;

  cla_1bit u0 (
      .a   (a[0]),
      .b   (b[0]),
      .cin (cin),
      .sum (s[0]),
      .cout(c_local[1]),
      .p   (p_local[0]),
      .g   (g_local[0])
  );

  cla_1bit u1 (
      .a   (a[1]),
      .b   (b[1]),
      .cin (c_local[1]),
      .sum (s[1]),
      .cout(c_local[2]),
      .p   (p_local[1]),
      .g   (g_local[1])
  );

  cla_1bit u2 (
      .a   (a[2]),
      .b   (b[2]),
      .cin (c_local[2]),
      .sum (s[2]),
      .cout(c_local[3]),
      .p   (p_local[2]),
      .g   (g_local[2])
  );

  cla_1bit u3 (
      .a   (a[3]),
      .b   (b[3]),
      .cin (c_local[3]),
      .sum (s[3]),
      .cout(cout),
      .p   (p_local[3]),
      .g   (g_local[3])
  );

  assign G = g_local[3] | (p_local[3] & g_local[2]) | (p_local[3] & p_local[2] & g_local[1]) | (p_local[3] & p_local[2] & p_local[1] & g_local[0]);
  assign P = p_local[3] & p_local[2] & p_local[1] & p_local[0];

endmodule

module cla_16bit (
  input  logic [15:0] a,
  input  logic [15:0] b,
  input  logic        cin,
  output logic [15:0] s,
  output logic        cout,
  output logic        P,
  output logic        G
);

  logic [3:1] c_local;
  logic [3:0] P_group;
  logic [3:0] G_group;

  cla_4bit u0 (
      .a   (a[3:0]),
      .b   (b[3:0]),
      .cin (cin),
      .s   (s[3:0]),
      .cout(c_local[1]),
      .P   (P_group[0]),
      .G   (G_group[0])
  );

  cla_4bit u1 (
      .a   (a[7:4]),
      .b   (b[7:4]),
      .cin (c_local[1]),
      .s   (s[7:4]),
      .cout(c_local[2]),
      .P   (P_group[1]),
      .G   (G_group[1])
  );

  cla_4bit u2 (
      .a   (a[11:8]),
      .b   (b[11:8]),
      .cin (c_local[2]),
      .s   (s[11:8]),
      .cout(c_local[3]),
      .P   (P_group[2]),
      .G   (G_group[2])
  );

  cla_4bit u3 (
      .a   (a[15:12]),
      .b   (b[15:12]),
      .cin (c_local[3]),
      .s   (s[15:12]),
      .cout(cout),
      .P   (P_group[3]),
      .G   (G_group[3])
  );

  assign G = G_group[3] | (P_group[3] & G_group[2]) | (P_group[3] & P_group[2] & G_group[1]) | (P_group[3] & P_group[2] & P_group[1] & G_group[0]);
  assign P = P_group[3] & P_group[2] & P_group[1] & P_group[0];

endmodule

module adder_32bit (
  input  logic [32:1] A,
  input  logic [32:1] B,
  output logic [32:1] S,
  output logic        C32
);

  logic c_mid;
  logic P_group_0;
  logic G_group_0;
  logic P_group_1;
  logic G_group_1;

  cla_16bit u0 (
      .a   (A[16:1]),
      .b   (B[16:1]),
      .cin (1'b0),
      .s   (S[16:1]),
      .cout(c_mid),
      .P   (P_group_0),
      .G   (G_group_0)
  );

  cla_16bit u1 (
      .a   (A[32:17]),
      .b   (B[32:17]),
      .cin (c_mid),
      .s   (S[32:17]),
      .cout(C32),
      .P   (P_group_1),
      .G   (G_group_1)
  );

endmodule