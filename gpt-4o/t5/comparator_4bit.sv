module comparator_4bit (
    input [3:0] A,
    input [3:0] B,
    output A_greater,
    output A_equal,
    output A_less
);
    wire [3:0] diff;
    wire borrow_out;

    assign {borrow_out, diff} = A - B;
    assign A_greater = ~borrow_out & |diff;
    assign A_equal = ~borrow_out & ~|diff;
    assign A_less = borrow_out;

endmodule