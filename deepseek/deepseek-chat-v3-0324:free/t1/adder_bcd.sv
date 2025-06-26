module adder_bcd(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout
);

    wire [4:0] sum_temp;
    wire correction;

    assign sum_temp = A + B + Cin;
    assign correction = (sum_temp > 9) ? 1'b1 : 1'b0;
    assign Sum = correction ? (sum_temp + 6) : sum_temp;
    assign Cout = correction;

endmodule