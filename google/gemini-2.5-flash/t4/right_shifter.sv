module right_shifter (
  input clk,
  input d,
  output reg [7:0] q
);

initial begin
  q = 8'b00000000;
end

always @(posedge clk) begin
  q <= (q >> 1);
  q[7] <= d;
end

endmodule