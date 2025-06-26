module adder_16bit(
    input [15:0] a,
    input [15:0] b,
    input Cin,
    output [15:0] y,
    output Co
);
    wire [7:0] sum0, sum1;
    wire c0, c1;

    // Instantiate two 8-bit adders
    adder_8bit adder0 (
        .a(a[7:0]),
        .b(b[7:0]),
        .Cin(Cin),
        .y(sum0),
        .Co(c0)
    );

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
    input [7:0] a,
    input [7:0] b,
    input Cin,
    output [7:0] y,
    output Co
);
    wire [7:0] p, g;
    wire [6:0] c;

    assign p = a ^ b;
    assign g = a & b;

    assign c[0] = g[0] | (p[0] & Cin);
    generate
        genvar i;
        for (i = 1; i < 7; i = i + 1) begin: carry_gen
            assign c[i] = g[i] | (p[i] & c[i-1]);
        end
    endgenerate
    assign c[7] = g[7] | (p[7] & c[6]);

    assign y = p ^ {c[6:0], Cin};
    assign Co = c[7];

endmodule