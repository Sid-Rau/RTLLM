module adder_16bit (
    input  [15:0] a,
    input  [15:0] b,
    input         Cin,
    output [15:0] y,
    output        Co
);
    wire [7:0] sum0, sum1;
    wire c1, c2;

    // 8-bit adder instance for lower 8 bits
    add8bit adder0 (
        .a(a[7:0]),
        .b(b[7:0]),
        .Cin(Cin),
        .y(sum0),
        .Co(c1)
    );

    // 8-bit adder instance for upper 8 bits
    add8bit adder1 (
        .a(a[15:8]),
        .b(b[15:8]),
        .Cin(c1),
        .y(sum1),
        .Co(c2)
    );

    assign y = {sum1, sum0};
    assign Co = c2;

endmodule

module add8bit (
    input  [7:0] a,
    input  [7:0] b,
    input        Cin,
    output [7:0] y,
    output       Co
);
    wire [7:0] p, g;
    wire [6:0] c;

    assign p = a ^ b;
    assign g = a & b;

    assign c[0] = g[0] | (p[0] & Cin);
    genvar i;
    generate
        for (i = 1; i < 8; i = i + 1) begin: carry_gen
            assign c[i] = g[i] | (p[i] & c[i-1]);
        end
    endgenerate

    assign y = p ^ {c, Cin};
    assign Co = c[7];

endmodule