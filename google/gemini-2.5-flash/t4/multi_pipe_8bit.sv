module multi_pipe_8bit (
  input clk,
  input rst_n,
  input mul_en_in,
  input [7:0] mul_a,
  input [7:0] mul_b,
  output mul_en_out,
  output [15:0] mul_out
);

  reg [7:0] mul_a_reg;
  reg [7:0] mul_b_reg;

  reg [2:0] mul_en_out_reg;
  assign mul_en_out = mul_en_out_reg[2];

  wire [7:0] temp [7:0]; // Partial products

  reg [15:0] sum [2:0]; // Partial sums

  reg [15:0] mul_out_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mul_a_reg <= 8'b0;
      mul_b_reg <= 8'b0;
      mul_en_out_reg <= 3'b0;
      sum[0] <= 16'b0;
      sum[1] <= 16'b0;
      sum[2] <= 16'b0;
      mul_out_reg <= 16'b0;
    end else begin
      if (mul_en_in) begin
        mul_a_reg <= mul_a;
        mul_b_reg <= mul_b;
      end

      mul_en_out_reg <= {mul_en_out_reg[1:0], mul_en_in};

      // Stage 1: Partial Products and first sum
      sum[0] <= (mul_b_reg[0] ? {8'b0, mul_a_reg} : 16'b0) +
                (mul_b_reg[1] ? {7'b0, mul_a_reg, 1'b0} : 16'b0) +
                (mul_b_reg[2] ? {6'b0, mul_a_reg, 2'b0} : 16'b0) +
                (mul_b_reg[3] ? {5'b0, mul_a_reg, 3'b0} : 16'b0);

      // Stage 2: Second sum
      sum[1] <= (mul_b_reg[4] ? {4'b0, mul_a_reg, 4'b0} : 16'b0) +
                (mul_b_reg[5] ? {3'b0, mul_a_reg, 5'b0} : 16'b0) +
                (mul_b_reg[6] ? {2'b0, mul_a_reg, 6'b0} : 16'b0) +
                (mul_b_reg[7] ? {1'b0, mul_a_reg, 7'b0} : 16'b0);
      
      // Stage 3: Final sum
      mul_out_reg <= sum[0] + sum[1];
    end
  end

  assign mul_out = mul_en_out ? mul_out_reg : 16'b0;

endmodule