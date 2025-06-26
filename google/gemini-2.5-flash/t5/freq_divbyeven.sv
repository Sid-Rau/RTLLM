module freq_divbyeven #(
  parameter NUM_DIV = 4 // Default division factor, must be an even number
) (
  input wire clk,
  input wire rst_n,
  output reg clk_div
);

  reg [3:0] cnt; // 4-bit counter

  initial begin
    clk_div = 1'b0;
    cnt = 4'b0;
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 4'b0;
      clk_div <= 1'b0;
    end else begin
      if (cnt == (NUM_DIV - 1)) begin
        cnt <= 4'b0;
        clk_div <= ~clk_div;
      end else begin
        cnt <= cnt + 4'b1;
      end
    end
  end

endmodule