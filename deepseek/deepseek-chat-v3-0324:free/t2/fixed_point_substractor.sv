module fixed_point_subtractor #(
    parameter Q = 16,
    parameter N = 32
) (
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output reg [N-1:0] c
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
            res = a - b;
            if (res == 0) begin
                c = 0;
            end else begin
                c = res;
            end
        end else begin
            if (a_sign == 0) begin
                res = a_abs + b_abs;
                if (a_abs >= b_abs) begin
                    c = {1'b0, res[N-2:0]};
                end else begin
                    c = {1'b1, res[N-2:0]};
                end
            end else begin
                res = a_abs + b_abs;
                if (a_abs > b_abs) begin
                    c = {1'b1, res[N-2:0]};
                end else begin
                    c = {1'b0, res[N-2:0]};
                end
            end
        end
    end

endmodule