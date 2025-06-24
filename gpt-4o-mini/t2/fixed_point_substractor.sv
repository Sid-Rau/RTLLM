module fixed_point_subtractor #(parameter Q = 16, parameter N = 32) (
    input [N-1:0] a,
    input [N-1:0] b,
    output reg [N-1:0] c
);
    reg [N-1:0] res;
    wire [N-1:0] abs_a, abs_b;
    wire sign_a, sign_b, sign_res;

    assign sign_a = a[N-1];
    assign sign_b = b[N-1];
    assign abs_a = sign_a ? (~a + 1) : a;
    assign abs_b = sign_b ? (~b + 1) : b;

    always @* begin
        if (sign_a == sign_b) begin
            res = sign_a ? (abs_b - abs_a) : (abs_a - abs_b);
            sign_res = res[N-1];
        end else begin
            res = abs_a + abs_b;
            sign_res = a > b ? sign_a : sign_b;
        end
        if (res == 0) begin
            c = 0;
        end else begin
            c = {sign_res, res[N-2:0]};
        end
    end
endmodule