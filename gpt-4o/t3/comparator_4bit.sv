module comparator_4bit(
    input [3:0] A,
    input [3:0] B,
    output A_greater,
    output A_equal,
    output A_less
);
    wire [3:0] diff;
    wire borrow;

    assign {borrow, diff} = {1'b0, A} - {1'b0, B};
    assign A_greater = ~borrow & (|diff);
    assign A_equal = ~(|diff);
    assign A_less = borrow;

endmodule