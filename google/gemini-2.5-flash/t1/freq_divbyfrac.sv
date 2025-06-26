module freq_divbyfrac (
  input clk,
  input rst_n,
  output clk_div
);

  localparam MUL2_DIV_CLK = 7; // 2 * 3.5 = 7

  reg [2:0]  count;
  reg        clk_div_int_a;
  reg        clk_div_int_b;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count         <= 3'd0;
      clk_div_int_a <= 1'b0;
      clk_div_int_b <= 1'b0;
    end else begin
      if (count == MUL2_DIV_CLK - 1) begin
        count <= 3'd0;
      end else begin
        count <= count + 3'd1;
      end

      // Generate clk_div_int_a (uneven periods: 4 and 3 clock cycles)
      if (count == MUL2_DIV_CLK - 1) begin
        clk_div_int_a <= 1'b0;
      end else if (count == 3) begin // High for 4 cycles (0,1,2,3)
        clk_div_int_a <= 1'b1;
      end

      // Generate clk_div_int_b (phase-shifted version of clk_div_int_a)
      if (count == MUL2_DIV_CLK - 1) begin
        clk_div_int_b <= 1'b1; // High for 3 cycles (4,5,6)
      end else if (count == 2) begin
        clk_div_int_b <= 1'b0;
      end
    end
  end

  assign clk_div = clk_div_int_a | clk_div_int_b;

endmodule