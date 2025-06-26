module fixed_point_subtractor #(
    parameter Q = 16,
    parameter N = 32
)(
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
            if (a_mag > b_mag) begin
                res = {a_sign, a_mag - b_mag};
            end else begin
                res = {~a_sign, b_mag - a_mag};
            end
        end else begin
            res = a_abs + b_abs;
            res[N-1] = (a_sign) ? (a_abs > b_abs) : (b_abs > a_abs);
        end

        if (res[N-2:0] == 0) begin
            res[N-1] = 1'b0;
        end
    end

    assign c = res;

endmodule