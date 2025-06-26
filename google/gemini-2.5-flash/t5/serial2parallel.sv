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
  end else begin
    dout_valid <= 1'b0; 
    if (din_valid) begin
      sipo_reg <= {sipo_reg[6:0], din_serial};
      if (cnt == 4'd7) begin
        cnt <= 4'b0;
        dout_parallel <= {sipo_reg[6:0], din_serial}; 
        dout_valid <= 1'b1;
      end else begin
        cnt <= cnt + 1'b1;
      end
    end
  end
end

endmodule