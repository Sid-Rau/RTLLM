module adder_bcd (
    input [3:0] A,
    input [3:0] B,
    input       Cin,
    output [3:0] Sum,
    output      Cout
);

wire [4:0] binary_sum;
wire       correction_needed;
wire [4:0] corrected_sum;

assign binary_sum = A + B + Cin;

assign correction_needed = (binary_sum > 9) || (binary_sum[3] && (binary_sum[2] || binary_sum[1]));

assign corrected_sum = correction_needed ? (binary_sum + 6) : binary_sum;

assign Sum = corrected_sum[3:0];
assign Cout = correction_needed;

endmodule