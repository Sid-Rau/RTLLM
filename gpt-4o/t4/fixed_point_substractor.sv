module fixed_point_subtractor #(parameter Q = 8, parameter N = 16)(
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output wire [N-1:0] c
);
    wire signed [N-1:0] signed_a;
    wire signed [N-1:0] signed_b;
    wire signed [N-1:0] signed_res;

    assign signed_a = a;
    assign signed_b = b;
    assign signed_res = signed_a - signed_b;

    assign c = signed_res;

endmodule