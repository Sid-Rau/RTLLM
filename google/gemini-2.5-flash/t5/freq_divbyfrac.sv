module freq_divbyfrac (
  input wire clk,
  input wire rst_n,
  output wire clk_div
);

  localparam MUL2_DIV_CLK = 7; // 2 * 3.5 = 7

  reg [2:0]  count;
  reg        clk_div_int_a;
  reg        clk_div_int_b;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      count <= 3'd0;
      clk_div_int_a <= 1'b0;
      clk_div_int_b <= 1'b0;
    end else begin
      count <= count + 3'd1;
      if (count == 3'd0) begin // Cycle 0
        clk_div_int_a <= 1'b1;
        clk_div_int_b <= 1'b0;
      end else if (count == 3'd3) begin // Cycle 3 (4th clock edge for clk_div_int_a)
        clk_div_int_a <= 1'b0;
      end else if (count == 3'd4) begin // Cycle 4 (start of next period for clk_div_int_b)
        clk_div_int_b <= 1'b1;
      end else if (count == 3'd6) begin // Cycle 6 (7th clock edge for clk_div_int_b)
        clk_div_int_b <= 1'b0;
      end
    end
  end

  assign clk_div = clk_div_int_a | clk_div_int_b;

endmodule