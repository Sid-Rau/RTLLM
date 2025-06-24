module adder_bcd(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
    wire [4:0] total;
    wire [3:0] sum_temp;
    wire carry_temp;

    assign total = A + B + Cin;
    assign carry_temp = (total > 9);
    assign sum_temp = total[3:0] + (carry_temp ? 4'b0110 : 4'b0000);
    assign Sum = sum_temp;
    assign Cout = carry_temp;

endmodule