module fixed_point_subtractor #(parameter Q = 8, parameter N = 16) (
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output reg [N-1:0] c
);

    reg [N-1:0] res;
    reg [N-1:0] abs_a, abs_b;
    reg sign_a, sign_b, sign_res;

    always @(*) begin
        sign_a = a[N-1];
        sign_b = b[N-1];
        abs_a = sign_a ? (~a + 1'b1) : a;
        abs_b = sign_b ? (~b + 1'b1) : b;

        if (sign_a == sign_b) begin
            res = abs_a - abs_b;
            sign_res = sign_a;
        end else begin
            res = abs_a + abs_b;
            sign_res = (abs_a >= abs_b) ? sign_a : sign_b;
        end

        if (res == 0) begin
            c = {1'b0, res[N-2:0]};
        end else begin
            c = sign_res ? (~res + 1'b1) : res;
        end
    end

endmodule