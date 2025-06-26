module adder_16bit(
    input [15:0] a,
    input [15:0] b,
    input Cin,
    output [15:0] y,
    output Co
);

    wire [1:0] carry;

    adder_8bit adder0 (
        .a(a[7:0]),
        .b(b[7:0]),
        .Cin(Cin),
        .y(y[7:0]),
        .Co(carry[0])
    );

    adder_8bit adder1 (
        .a(a[15:8]),
        .b(b[15:8]),
        .Cin(carry[0]),
        .y(y[15:8]),
        .Co(carry[1])
    );

    assign Co = carry[1];

endmodule

module adder_8bit(
    input [7:0] a,
    input [7:0] b,
    input Cin,
    output [7:0] y,
    output Co
);

    wire [7:0] carry;

    full_adder fa0 (.a(a[0]), .b(b[0]), .Cin(Cin), .y(y[0]), .Co(carry[0]));
    full_adder fa1 (.a(a[1]), .b(b[1]), .Cin(carry[0]), .y(y[1]), .Co(carry[1]));
    full_adder fa2 (.a(a[2]), .b(b[2]), .Cin(carry[1]), .y(y[2]), .Co(carry[2]));
    full_adder fa3 (.a(a[3]), .b(b[3]), .Cin(carry[2]), .y(y[3]), .Co(carry[3]));
    full_adder fa4 (.a(a[4]), .b(b[4]), .Cin(carry[3]), .y(y[4]), .Co(carry[4]));
    full_adder fa5 (.a(a[5]), .b(b[5]), .Cin(carry[4]), .y(y[5]), .Co(carry[5]));
    full_adder fa6 (.a(a[6]), .b(b[6]), .Cin(carry[5]), .y(y[6]), .Co(carry[6]));
    full_adder fa7 (.a(a[7]), .b(b[7]), .Cin(carry[6]), .y(y[7]), .Co(carry[7]));

    assign Co = carry[7];

endmodule

module full_adder(
    input a,
    input b,
    input Cin,
    output y,
    output Co
);

    assign y = a ^ b ^ Cin;
    assign Co = (a & b) | (a & Cin) | (b & Cin);

endmodule