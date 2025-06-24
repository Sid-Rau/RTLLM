module adder_bcd(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
    wire [4:0] binary_sum;
    wire [4:0] corrected_sum;

    assign binary_sum = A + B + Cin;
    assign corrected_sum = binary_sum + 5'b00110;

    assign Cout = (binary_sum > 4'b1001);
    assign Sum = Cout ? corrected_sum[3:0] : binary_sum[3:0];

endmodule