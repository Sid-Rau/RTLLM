module fixed_point_adder #(parameter Q = 16, parameter N = 32) (
    input  [N-1:0] a,
    input  [N-1:0] b,
    output [N-1:0] c
);
    reg [N-1:0] res;

    always @* begin
        if (a[N-1] == b[N-1]) begin
            res = a + b;
            res[N-1] = a[N-1];
        end else begin
            if (a[N-1] == 0 && (a > b)) begin
                res = a - b;
                res[N-1] = 0;
            end else if (b[N-1] == 0 && (b > a)) begin
                res = b - a;
                res[N-1] = 0;
            end else begin
                if (a[N-1] == 1) begin
                    res = b - a;
                    res[N-1] = (res == 0) ? 0 : 1;
                end else begin
                    res = a - b;
                    res[N-1] = (res == 0) ? 0 : 1;
                end
            end
        end
    end

    assign c = res;

endmodule