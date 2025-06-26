module serial2parallel (
  input wire clk,
  input wire rst_n,
  input wire din_serial,
  input wire din_valid,
  output reg [7:0] dout_parallel,
  output reg dout_valid
);

  reg [3:0] cnt;
  reg [7:0] sipo_reg;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 4'b0;
      sipo_reg <= 8'b0;
      dout_valid <= 1'b0;
      dout_parallel <= 8'b0;
    end else begin
      dout_valid <= 1'b0; // Default to 0, set to 1 only when all 8 bits are received

      if (din_valid) begin
        sipo_reg <= {sipo_reg[6:0], din_serial};
        if (cnt == 4'd7) begin // If this is the 8th bit
          dout_parallel <= {sipo_reg[6:0], din_serial}; // Update with the current bit as MSB
          dout_valid <= 1'b1;
          cnt <= 4'b0; // Reset counter for next 8 bits
        end else begin
          cnt <= cnt + 4'b1;
        end
      end
    end
  end

endmodule