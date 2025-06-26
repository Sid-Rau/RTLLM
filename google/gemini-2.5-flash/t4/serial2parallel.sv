module serial2parallel (
  input wire clk,
  input wire rst_n,
  input wire din_serial,
  input wire din_valid,
  output reg [7:0] dout_parallel,
  output reg dout_valid
);

  reg [3:0] cnt;
  reg [7:0] data_buffer;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 4'b0000;
      data_buffer <= 8'b00000000;
      dout_valid <= 1'b0;
      dout_parallel <= 8'b00000000;
    end else begin
      dout_valid <= 1'b0; // Default to 0, set to 1 only when valid

      if (din_valid) begin
        data_buffer <= {data_buffer[6:0], din_serial};
        if (cnt == 4'd7) begin
          cnt <= 4'b0000;
          dout_parallel <= {data_buffer[6:0], din_serial}; // Final bit completes the 8 bits
          dout_valid <= 1'b1;
        end else begin
          cnt <= cnt + 1;
        end
      end
    end
  end

endmodule