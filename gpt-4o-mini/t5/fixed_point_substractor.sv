module fixed_point_subtractor #(parameter Q = 16, parameter N = 32) (
    input [N-1:0] a,
    input [N-1:0] b,
    output reg [N-1:0] c
);
    reg [N-1:0] res;
    wire sign_a = a[N-1];
    wire sign_b = b[N-1];
    wire [N-1:0] abs_a = sign_a ? (~a + 1) : a;
    wire [N-1:0] abs_b = sign_b ? (~b + 1) : b;

    always @(*) begin
        if (sign_a == sign_b) begin
            res = sign_a ? (~abs_a + abs_b) : (abs_a - abs_b);
            c = (res == 0) ? 0 : {res[N-1], res[N-2:0]};
        end else begin
            if (abs_a > abs_b) begin
                res = abs_a + abs_b;
                c = {1'b0, res[N-2:0]};
            end else begin
                res = abs_b + abs_a;
                c = {1'b1, res[N-2:0]};
            end
        end
    end
endmodule