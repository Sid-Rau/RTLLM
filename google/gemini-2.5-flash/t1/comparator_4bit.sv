module comparator_4bit (
  input  [3:0] A,
  input  [3:0] B,
  output       A_greater,
  output       A_equal,
  output       A_less
);

  wire [3:0] diff;
  wire       borrow;

  assign {borrow, diff} = A - B;

  assign A_equal   = (diff == 4'b0000) && (borrow == 1'b0);
  assign A_greater = (borrow == 1'b0) && (diff != 4'b0000);
  assign A_less    = (borrow == 1'b1);

endmodule