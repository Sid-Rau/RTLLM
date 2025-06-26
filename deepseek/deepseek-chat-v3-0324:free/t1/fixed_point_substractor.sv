module fixed_point_subtractor #(
    parameter Q = 16,
    parameter N = 32
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
    wire [N-1:0] sum = a_abs + b_abs;
    wire [N-1:0] diff = a_abs - b_abs;
    wire diff_sign = a_sign ^ b_sign;

    always @(*) begin
        if (a_sign == b_sign) begin
            res[N-1] = a_sign;
            res[N-2:0] = a_mag - b_mag;
        end else begin
            if (a_abs > b_abs) begin
                res[N-1] = a_sign;
                res[N-2:0] = diff[N-2:0];
            end else if (a_abs < b_abs) begin
                res[N-1] = b_sign;
                res[N-2:0] = diff[N-2:0];
            end else begin
                res = {1'b0, {(N-1){1'b0}}};
            end
        end
    end

    assign c = res;

endmodule