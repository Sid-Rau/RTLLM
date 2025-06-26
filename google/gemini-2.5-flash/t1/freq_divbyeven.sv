module freq_divbyeven #(parameter NUM_DIV = 4)
(
  input clk,
  input rst_n,
  output reg clk_div
);

  reg [3:0] cnt;

  initial begin
    if (NUM_DIV % 2 != 0) begin
      $error("NUM_DIV must be an even number.");
      $finish;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 4'd0;
      clk_div <= 1'b0;
    end else begin
      if (cnt == (NUM_DIV / 2) - 1) begin
        cnt <= 4'd0;
        clk_div <= ~clk_div;
      end else begin
        cnt <= cnt + 4'd1;
      end
    end
  end

endmodule