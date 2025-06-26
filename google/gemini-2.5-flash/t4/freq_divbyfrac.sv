module freq_divbyfrac (
  input clk,
  input rst_n,
  output clk_div
);

  localparam MUL2_DIV_CLK = 7; // 2 * 3.5 = 7

  reg [2:0]  count;
  reg        clk_div_int_a;
  reg        clk_div_int_b;
  reg        clk_div_int_a_d;
  reg        clk_div_int_b_d;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 3'd0;
      clk_div_int_a <= 1'b0;
      clk_div_int_b <= 1'b0;
    end else begin
      count <= (count == MUL2_DIV_CLK - 1) ? 3'd0 : count + 3'd1;

      if (count == 3'd0) begin
        clk_div_int_a <= 1'b1;
        clk_div_int_b <= 1'b0;
      end else if (count == 3'd4) begin // 4 clock cycles for the first half
        clk_div_int_a <= 1'b0;
      end else if (count == 3'd3) begin // 3 clock cycles for the second half
        clk_div_int_b <= 1'b1;
      end else if (count == 3'd6) begin
        clk_div_int_b <= 1'b0;
      end
    end
  end

  // Generate phase-shifted versions for double-edge clocking
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clk_div_int_a_d <= 1'b0;
      clk_div_int_b_d <= 1'b0;
    end else begin
      clk_div_int_a_d <= clk_div_int_a;
      clk_div_int_b_d <= clk_div_int_b;
    end
  end

  assign clk_div = clk_div_int_a_d | clk_div_int_b;

endmodule