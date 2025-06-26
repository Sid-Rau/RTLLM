module fixed_point_adder #(
    parameter Q = 8,
    parameter N = 16
)(
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
);

    reg [N-1:0] res;
    reg [N-1:0] abs_a;
    reg [N-1:0] abs_b;
    reg [N-1:0] sum;
    reg [N-1:0] diff;
    reg sign_a;
    reg sign_b;
    reg sign_sum;
    reg sign_diff;

    always @(*) begin
        sign_a = a[N-1];
        sign_b = b[N-1];
        abs_a = sign_a ? -a : a;
        abs_b = sign_b ? -b : b;

        if (sign_a == sign_b) begin
            sum = abs_a + abs_b;
            sign_sum = sign_a;
            res = sign_sum ? -sum : sum;
        end else begin
            if (abs_a > abs_b) begin
                diff = abs_a - abs_b;
                sign_diff = sign_a;
            end else begin
                diff = abs_b - abs_a;
                sign_diff = sign_b;
            end
            res = sign_diff ? -diff : diff;
        end
    end

    assign c = res;

endmodule