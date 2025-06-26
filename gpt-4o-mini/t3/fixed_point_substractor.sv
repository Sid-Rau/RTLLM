module fixed_point_subtractor #(parameter Q = 16, parameter N = 32) (
    input  [N-1:0] a,
    input  [N-1:0] b,
    output [N-1:0] c
);
    reg [N-1:0] res;

    always @(*) begin
        if (a[N-1] == b[N-1]) begin
            res = a - b;
            if (res == 0) begin
                res[N-1] = 0;
            end else begin
                res[N-1] = a[N-1];
            end
        end else begin
            if (a[N-1] == 0 && b[N-1] == 1) begin
                if (a > {1'b0, b[N-2:0]}) begin
                    res = a + {1'b0, b[N-2:0]};
                    res[N-1] = 0;
                end else begin
                    res = {1'b1, {N-1{1'b0}}} + a + {1'b0, b[N-2:0]};
                    res[N-1] = 1;
                end
            end else if (a[N-1] == 1 && b[N-1] == 0) begin
                if (b > {1'b0, a[N-2:0]}) begin
                    res = b + {1'b0, a[N-2:0]};
                    res[N-1] = 0;
                end else begin
                    res = {1'b1, {N-1{1'b0}}} + b + {1'b0, a[N-2:0]};
                    res[N-1] = 1;
                end
            end
        end
    end

    assign c = res;

endmodule