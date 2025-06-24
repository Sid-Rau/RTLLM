module adder_16bit(
    input  [15:0] a,
    input  [15:0] b,
    input         Cin,
    output [15:0] y,
    output        Co
);
    wire [7:0] sum0, sum1;
    wire c0, c1;

    // 8-bit adder instance for lower 8 bits
    adder_8bit adder0 (
        .a(a[7:0]),
        .b(b[7:0]),
        .Cin(Cin),
        .y(sum0),
        .Co(c0)
    );

    // 8-bit adder instance for upper 8 bits
    adder_8bit adder1 (
        .a(a[15:8]),
        .b(b[15:8]),
        .Cin(c0),
        .y(sum1),
        .Co(c1)
    );

    assign y = {sum1, sum0};
    assign Co = c1;

endmodule

module adder_8bit(
    input  [7:0] a,
    input  [7:0] b,
    input        Cin,
    output [7:0] y,
    output       Co
);
    wire [8:0] temp;

    assign temp = a + b + Cin;
    assign y = temp[7:0];
    assign Co = temp[8];

endmodule