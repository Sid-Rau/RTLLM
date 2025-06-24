module adder_16bit(
    input  [15:0] a,
    input  [15:0] b,
    input         Cin,
    output [15:0] y,
    output        Co
);
    wire [7:0] sum0, sum1;
    wire carry0, carry1;

    // 8-bit adder instance for lower 8 bits
    adder_8bit adder0 (
        .a(a[7:0]),
        .b(b[7:0]),
        .Cin(Cin),
        .y(sum0),
        .Co(carry0)
    );

    // 8-bit adder instance for upper 8 bits
    adder_8bit adder1 (
        .a(a[15:8]),
        .b(b[15:8]),
        .Cin(carry0),
        .y(sum1),
        .Co(carry1)
    );

    assign y = {sum1, sum0};
    assign Co = carry1;

endmodule

module adder_8bit(
    input  [7:0] a,
    input  [7:0] b,
    input        Cin,
    output [7:0] y,
    output       Co
);
    wire [8:0] sum;

    assign sum = a + b + Cin;
    assign y = sum[7:0];
    assign Co = sum[8];

endmodule