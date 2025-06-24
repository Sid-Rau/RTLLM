module adder_bcd (
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
    wire [4:0] temp_sum;
    wire [3:0] corrected_sum;
    wire correction_needed;

    assign temp_sum = A + B + Cin;
    assign correction_needed = (temp_sum > 4'd9);
    assign corrected_sum = correction_needed ? (temp_sum + 4'b0110) : temp_sum;
    assign Sum = corrected_sum[3:0];
    assign Cout = correction_needed;

endmodule