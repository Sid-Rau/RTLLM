module fixed_point_adder #(
    parameter Q = 8,
    parameter N = 16
) (
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
);

    reg [N-1:0] res;
    reg [N-1:0] abs_a;
    reg [N-1:0] abs_b;
    reg [N-1:0] sum;
    reg [N-1:0] diff;

    always @(*) begin
        abs_a = a[N-1] ? (~a + 1'b1) : a;
        abs_b = b[N-1] ? (~b + 1'b1) : b;

        if (a[N-1] == b[N-1]) begin
            sum = abs_a + abs_b;
            res = {a[N-1], sum[N-2:0]};
        end else begin
            if (abs_a > abs_b) begin
                diff = abs_a - abs_b;
                res = diff == 0 ? 0 : {1'b0, diff[N-2:0]};
            end else begin
                diff = abs_b - abs_a;
                res = diff == 0 ? 0 : {1'b1, diff[N-2:0]};
            end
        end
    end

    assign c = res;

endmodule