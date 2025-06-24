module fixed_point_subtractor #(parameter Q = 8, parameter N = 16) (
    input signed [N-1:0] a,
    input signed [N-1:0] b,
    output signed [N-1:0] c
);
    reg signed [N-1:0] res;
    
    always @(*) begin
        if (a[N-1] == b[N-1]) begin
            res = a - b;
        end else begin
            if (a[N-1] == 0) begin
                res = a + b;
            end else begin
                res = a + b;
            end
        end
        if (res == 0)
            res[N-1] = 0;
    end
    
    assign c = res;
endmodule