module freq_divbyfrac (
  input  clk,
  input  rst_n,
  output clk_div
);

  localparam MUL2_DIV_CLK = 7; // 2 * 3.5 = 7

  reg [2:0] counter;
  reg       clk_div_raw;
  reg       clk_div_shifted;

  // Counter to generate the raw divided clock
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 3'd0;
      clk_div_raw <= 1'b0;
    end else begin
      if (counter == MUL2_DIV_CLK - 1) begin
        counter <= 3'd0;
        clk_div_raw <= ~clk_div_raw; // Toggle for 3.5x division, 7 cycles for full period
      end else begin
        counter <= counter + 3'd1;
      end
    end
  end

  // Generate the phase-shifted clock
  // This effectively creates a clock that toggles on the negative edge of the raw clock
  // or half a clock cycle later than the raw clock's positive edge.
  always @(negedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clk_div_shifted <= 1'b0;
    end else begin
      // This logic creates a signal that toggles when the raw clock is high and clk goes low,
      // or when the raw clock is low and clk goes low.
      // Effectively, it captures the state of clk_div_raw at the negative edge of clk.
      // This creates the "half-period" shift.
      clk_div_shifted <= clk_div_raw;
    end
  end

  // OR the raw and shifted clocks to get the final fractional divided clock
  assign clk_div = clk_div_raw | clk_div_shifted;

endmodule