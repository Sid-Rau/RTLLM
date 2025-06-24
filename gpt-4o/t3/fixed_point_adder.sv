module fixed_point_adder #(parameter Q = 8, parameter N = 16) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] c
);

    wire signed [N-1:0] a_signed = a;
    wire signed [N-1:0] b_signed = b;
    wire signed [N-1:0] sum;
    wire signed [N-1:0] diff;

    assign sum = a_signed + b_signed;
    assign diff = a_signed - b_signed;

    assign c = (a[N-1] == b[N-1]) ? sum : 
               (a_signed > b_signed) ? diff : -diff;

endmodule