module fixed_point_subtractor #(
    parameter Q = 16,
    parameter N = 32
)(
    input signed [N-1:0] a,
    input signed [N-1:0] b,
    output reg signed [N-1:0] c
);

    reg signed [N-1:0] res;
    reg a_sign, b_sign;
    reg [N-2:0] a_mag, b_mag;
    reg [N-1:0] abs_a, abs_b;

    always @(*) begin
        a_sign = a[N-1];
        b_sign = b[N-1];
        abs_a = a_sign ? -a : a;
        abs_b = b_sign ? -b : b;
        a_mag = abs_a[N-2:0];
        b_mag = abs_b[N-2:0];

        if (a_sign == b_sign) begin
            res = a - b;
            if (res == 0) begin
                res[N-1] = 1'b0;
            end
        end else begin
            if (a_sign) begin
                res = - (abs_a + abs_b);
            end else begin
                res = abs_a + abs_b;
            end
        end
        c = res;
    end

endmodule