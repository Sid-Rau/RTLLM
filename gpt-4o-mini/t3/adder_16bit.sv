module adder_16bit(
    input [15:0] a,
    input [15:0] b,
    input Cin,
    output [15:0] y,
    output Co
);
    wire [7:0] sum0, sum1;
    wire c0, c1;

    // 8-bit adder instance for lower 8 bits
    assign {c0, sum0} = a[7:0] + b[7:0] + Cin;

    // 8-bit adder instance for upper 8 bits
    assign {c1, sum1} = a[15:8] + b[15:8] + c0;

    assign y = {sum1, sum0};
    assign Co = c1;
endmodule