module comparator_4bit (
  input  [3:0] A,
  input  [3:0] B,
  output       A_greater,
  output       A_equal,
  output       A_less
);

  wire [4:0] diff;

  assign diff = A - B;

  assign A_equal   = (diff == 5'b00000);
  assign A_greater = (diff[4] == 1'b0) && (diff != 5'b00000);
  assign A_less    = (diff[4] == 1'b1);

endmodule