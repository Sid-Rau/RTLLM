module comparator_4bit (
  input  [3:0] A,
  input  [3:0] B,
  output       A_greater,
  output       A_equal,
  output       A_less
);

  wire [4:0] diff_result; // 4-bit result + 1-bit borrow/carry out

  assign diff_result = A - B;

  assign A_equal   = (diff_result[3:0] == 4'b0000);
  assign A_greater = (diff_result[4] == 1'b0) && (diff_result[3:0] != 4'b0000); // No borrow and non-zero
  assign A_less    = (diff_result[4] == 1'b1);                                 // Borrow occurred

endmodule