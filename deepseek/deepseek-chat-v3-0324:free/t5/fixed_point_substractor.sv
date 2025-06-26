module fixed_point_subtractor #(
    parameter Q = 8,
    parameter N = 16
) (
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output reg [N-1:0] c
);

    reg [N-1:0] res;
    reg a_sign, b_sign;
    reg [N-2:0] a_mag, b_mag;
    reg [N-1:0] a_abs, b_abs;

    always @* begin
        a_sign = a[N-1];
        b_sign = b[N-1];
        a_mag = a[N-2:0];
        b_mag = b[N-2:0];
        a_abs = {1'b0, a_mag};
        b_abs = {1'b0, b_mag};

        if (a_sign == b_sign) begin
            res = a - b;
            if (res == 0)
                res[N-1] = 1'b0;
        end else begin
            if (a_sign == 0) begin
                res = a_abs + b_abs;
                res[N-1] = (a_abs >= b_abs) ? 1'b0 : 1'b1;
            end else begin
                res = a_abs + b_abs;
                res[N-1] = (a_abs > b_abs) ? 1'b1 : 1'b0;
            end
        end
        c = res;
    end

endmodule