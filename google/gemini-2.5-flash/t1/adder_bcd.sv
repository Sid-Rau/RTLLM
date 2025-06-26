module adder_bcd (
    input [3:0] A,
    input [3:0] B,
    input       Cin,
    output [3:0] Sum,
    output      Cout
);

wire [4:0] sum_binary;
wire       correction_needed;
wire [4:0] sum_corrected;

assign sum_binary = A + B + Cin;

assign correction_needed = (sum_binary > 9) || (sum_binary[3:0] > 9);

assign sum_corrected = correction_needed ? (sum_binary + 6) : sum_binary;

assign Sum = sum_corrected[3:0];
assign Cout = correction_needed || sum_binary[4];

endmodule