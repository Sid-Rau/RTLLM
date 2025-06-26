module freq_divbyfrac (
  input  clk,
  input  rst_n,
  output clk_div
);

  localparam MUL2_DIV_CLK = 7; // 2 * 3.5 = 7

  reg [2:0] counter;
  reg       clk_div_raw_a;
  reg       clk_div_raw_b;
  reg       clk_div_raw_c;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter       <= 3'd0;
      clk_div_raw_a <= 1'b0;
      clk_div_raw_b <= 1'b0;
      clk_div_raw_c <= 1'b0;
    end else begin
      counter <= (counter == MUL2_DIV_CLK - 1) ? 3'd0 : counter + 3'd1;

      // Generate clk_div_raw_a (4 cycles ON, 3 cycles OFF)
      if (counter == 3'd0) begin
        clk_div_raw_a <= 1'b1;
      end else if (counter == 3'd4) begin
        clk_div_raw_a <= 1'b0;
      end

      // Generate clk_div_raw_b (3 cycles ON, 4 cycles OFF)
      if (counter == 3'd0) begin
        clk_div_raw_b <= 1'b1;
      end else if (counter == 3'd3) begin
        clk_div_raw_b <= 1'b0;
      end

      // Generate clk_div_raw_c (phase-shifted version of clk_div_raw_b)
      // This is effectively clk_div_raw_b delayed by 1 clock cycle for the half-cycle shift.
      clk_div_raw_c <= clk_div_raw_b;
    end
  end

  assign clk_div = clk_div_raw_a | clk_div_raw_c;

endmodule