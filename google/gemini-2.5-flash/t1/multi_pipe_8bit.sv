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

  wire [7:0] temp [7:0]; // Partial products

  reg [8:0] sum [6:0]; // Partial sums
  reg [15:0] mul_out_reg;

  assign mul_en_out = mul_en_out_reg[7];

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

  // Partial Product Generation
  generate
    genvar i;
    for (i = 0; i < 8; i = i + 1) begin
      assign temp[i] = mul_b_reg[i] ? mul_a_reg : 8'b0;
    end
  endgenerate

  // Partial Sum Calculation
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sum[0] <= 9'b0;
      sum[1] <= 9'b0;
      sum[2] <= 9'b0;
      sum[3] <= 9'b0;
      sum[4] <= 9'b0;
      sum[5] <= 9'b0;
      sum[6] <= 9'b0;
    end else begin
      sum[0] <= {1'b0, temp[0]} + {1'b0, temp[1]};
      sum[1] <= {1'b0, temp[2]} + {1'b0, temp[3]};
      sum[2] <= {1'b0, temp[4]} + {1'b0, temp[5]};
      sum[3] <= {1'b0, temp[6]} + {1'b0, temp[7]};
      sum[4] <= {1'b0, sum[0][8:0]} + {1'b0, sum[1][8:0]};
      sum[5] <= {1'b0, sum[2][8:0]} + {1'b0, sum[3][8:0]};
      sum[6] <= {1'b0, sum[4][8:0]} + {1'b0, sum[5][8:0]};
    end
  end

  // Final Product Calculation
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      mul_out_reg <= 16'b0;
    end else begin
      mul_out_reg <= {7'b0, sum[6][8:0]};
    end
  end

  // Output Assignment
  assign mul_out = mul_en_out ? mul_out_reg : 16'b0;

endmodule