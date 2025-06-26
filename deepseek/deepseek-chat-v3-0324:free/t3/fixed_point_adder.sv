module fixed_point_adder #(
    parameter Q = 8,
    parameter N = 16
) (
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
);

    reg [N-1:0] res;
    wire [N-1:0] abs_a = a[N-1] ? ~a + 1'b1 : a;
    wire [N-1:0] abs_b = b[N-1] ? ~b + 1'b1 : b;
    wire [N-1:0] sum = abs_a + abs_b;
    wire [N-1:0] diff = abs_a > abs_b ? abs_a - abs_b : abs_b - abs_a;
    wire diff_sign = abs_a > abs_b ? a[N-1] : b[N-1];

    always @(*) begin
        if (a[N-1] == b[N-1]) begin
            res[N-1] = a[N-1];
            res[N-2:0] = sum[N-2:0];
        end else begin
            res[N-1] = (diff == 0) ? 1'b0 : diff_sign;
            res[N-2:0] = diff[N-2:0];
        end
    end

    assign c = res;

endmodule