module fixed_point_subtractor #(parameter Q = 16, parameter N = 32) (
    input [N-1:0] a,
    input [N-1:0] b,
    output reg [N-1:0] c
);
    reg [N-1:0] res;
    always @(*) begin
        if (a[N-1] == b[N-1]) begin
            res = a - b;
            if (res == 0) begin
                c = 0;
            end else begin
                c = res;
            end
        end else begin
            if (a[N-1] == 0 && b[N-1] == 1) begin
                res = a + (~b + 1);
                c = (a > b) ? res : ~res + 1;
            end else if (a[N-1] == 1 && b[N-1] == 0) begin
                res = b + (~a + 1);
                c = (b > a) ? res : ~res + 1;
            end
        end
    end
endmodule