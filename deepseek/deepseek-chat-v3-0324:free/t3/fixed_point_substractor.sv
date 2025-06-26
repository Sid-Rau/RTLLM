module fixed_point_subtractor #(
    parameter Q = 8,
    parameter N = 16
) (
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
);

    reg [N-1:0] res;
    wire a_sign = a[N-1];
    wire b_sign = b[N-1];
    wire [N-2:0] a_mag = a[N-2:0];
    wire [N-2:0] b_mag = b[N-2:0];
    wire [N-1:0] a_abs = {1'b0, a_mag};
    wire [N-1:0] b_abs = {1'b0, b_mag};

    always @(*) begin
        if (a_sign == b_sign) begin
            res[N-2:0] = a_mag - b_mag;
            res[N-1] = a_sign;
            if (res[N-2:0] == 0) res[N-1] = 0;
        end
        else begin
            if (a_sign == 0) begin
                res[N-1:0] = a_abs + b_abs;
                res[N-1] = (a_abs >= b_abs) ? 0 : 1;
            end
            else begin
                res[N-1:0] = a_abs + b_abs;
                res[N-1] = (b_abs >= a_abs) ? 0 : 1;
            end
        end
    end

    assign c = res;

endmodule