module fixed_point_adder #(parameter Q = 8, parameter N = 16)(
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output wire [N-1:0] c
);
    wire signed [N-1:0] a_signed = a;
    wire signed [N-1:0] b_signed = b;
    wire signed [N-1:0] sum;
    
    assign sum = a_signed + b_signed;
    assign c = sum[N-1:0];

endmodule