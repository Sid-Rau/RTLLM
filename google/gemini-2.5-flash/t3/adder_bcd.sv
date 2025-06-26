module adder_bcd (
    input [3:0] A,
    input [3:0] B,
    input       Cin,
    output [3:0] Sum,
    output      Cout
);

wire [4:0] sum_binary;
wire       carry_out_binary;
wire       correction_needed;
wire [4:0] sum_corrected;

assign sum_binary = A + B + Cin;
assign carry_out_binary = sum_binary[4];

assign correction_needed = carry_out_binary | (sum_binary > 4'd9);

assign sum_corrected = correction_needed ? (sum_binary + 5'd6) : sum_binary;

assign Sum = sum_corrected[3:0];
assign Cout = correction_needed;

endmodule