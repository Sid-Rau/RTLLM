module adder_32bit(A, B, S, C32);
  input [32:1] A, B;
  output [32:1] S;
  output C32;

  wire [16:1] S1, S2;
  wire C16, C32_internal;

  cla_16bit adder1(.A(A[16:1]), .B(B[16:1]), .Cin(1'b0), .S(S1), .Cout(C16));
  cla_16bit adder2(.A(A[32:17]), .B(B[32:17]), .Cin(C16), .S(S2), .Cout(C32_internal));

  assign S = {S2, S1};
  assign C32 = C32_internal;
endmodule

module cla_16bit(A, B, Cin, S, Cout);
  input [16:1] A, B;
  input Cin;
  output [16:1] S;
  output Cout;

  wire [16:0] G, P, C;

  assign G = {A & B, 1'b0};
  assign P = {A ^ B, 1'b0};
  assign C[0] = Cin;

  genvar i;
  generate
    for (i = 1; i <= 16; i = i + 1) begin: carry_gen
      assign C[i] = G[i] | (P[i] & C[i-1]);
    end
  endgenerate

  assign S = P[16:1] ^ C[15:0];
  assign Cout = C[16];
endmodule