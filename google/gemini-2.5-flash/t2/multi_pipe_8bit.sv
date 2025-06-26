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
  reg [7:0] mul_en_out_reg;

  wire [7:0] temp [7:0];
  reg [15:0] sum [7:0];
  reg [15:0] mul_out_reg;

  // Input Registers
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mul_a_reg <= 8'b0;
      mul_b_reg <= 8'b0;
      mul_en_out_reg <= 8'b0;
    end else begin
      if (mul_en_in) begin
        mul_a_reg <= mul_a;
        mul_b_reg <= mul_b;
      end
      mul_en_out_reg <= {mul_en_out_reg[6:0], mul_en_in};
    end
  end

  assign mul_en_out = mul_en_out_reg[7];

  // Partial Product Generation
  generate
    genvar i;
    for (i = 0; i < 8; i = i + 1) begin : gen_partial_products
      assign temp[i] = mul_b_reg[i] ? mul_a_reg : 8'b0;
    end
  endgenerate

  // Partial Sum Calculation
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sum[0] <= 16'b0;
      sum[1] <= 16'b0;
      sum[2] <= 16'b0;
      sum[3] <= 16'b0;
      sum[4] <= 16'b0;
      sum[5] <= 16'b0;
      sum[6] <= 16'b0;
      sum[7] <= 16'b0;
    end else begin
      sum[0] <= {8'b0, temp[0]};
      sum[1] <= sum[0] + ({7'b0, temp[1], 1'b0});
      sum[2] <= sum[1] + ({6'b0, temp[2], 2'b0});
      sum[3] <= sum[2] + ({5'b0, temp[3], 3'b0});
      sum[4] <= sum[3] + ({4'b0, temp[4], 4'b0});
      sum[5] <= sum[4] + ({3'b0, temp[5], 5'b0});
      sum[6] <= sum[5] + ({2'b0, temp[6], 6'b0});
      sum[7] <= sum[6] + ({1'b0, temp[7], 7'b0});
    end
  end

  // Final Product Calculation
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mul_out_reg <= 16'b0;
    end else begin
      mul_out_reg <= sum[7];
    end
  end

  // Output Assignment
  assign mul_out = mul_en_out ? mul_out_reg : 16'b0;

endmodule