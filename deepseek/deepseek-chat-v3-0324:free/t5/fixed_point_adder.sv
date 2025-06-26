module fixed_point_adder #(
    parameter Q = 8,
    parameter N = 16
) (
    input [N-1:0] a,
    input [N-1:0] b,
    output [N-1:0] c
);

    reg [N-1:0] res;
    wire [N-1:0] a_mag = a[N-2:0];
    wire [N-1:0] b_mag = b[N-2:0];
    wire a_sign = a[N-1];
    wire b_sign = b[N-1];
    wire [N-1:0] sum = {1'b0, a_mag} + {1'b0, b_mag};
    wire [N-1:0] diff_ab = {1'b0, a_mag} - {1'b0, b_mag};
    wire [N-1:0] diff_ba = {1'b0, b_mag} - {1'b0, a_mag};

    always @(*) begin
        if (a_sign == b_sign) begin
            res = {a_sign, sum[N-2:0]};
        end else begin
            if (a_mag > b_mag) begin
                res = {1'b0, diff_ab[N-2:0]};
                if (diff_ab[N-2:0] == 0) res[N-1] = 1'b0;
                else res[N-1] = a_sign;
            end else if (b_mag > a_mag) begin
                res = {1'b0, diff_ba[N-2:0]};
                if (diff_ba[N-2:0] == 0) res[N-1] = 1'b0;
                else res[N-1] = b_sign;
            end else begin
                res = 0;
            end
        end
    end

    assign c = res;

endmodule