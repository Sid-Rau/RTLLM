module fixed_point_subtractor #(parameter Q = 16, parameter N = 32) (
    input  [N-1:0] a,
    input  [N-1:0] b,
    output [N-1:0] c
);
    reg [N-1:0] res;

    always @(*) begin
        if (a[N-1] == b[N-1]) begin
            res = a - b;
        end else if (a[N-1] == 1'b0 && b[N-1] == 1'b1) begin
            res = a + {1'b0, ~b[N-2:0] + 1'b1}; 
        end else if (a[N-1] == 1'b1 && b[N-1] == 1'b0) begin
            res = {1'b0, a[N-2:0]} + b; 
        end else begin
            res = 0;
        end
        
        if (res == 0) begin
            res[N-1] = 1'b0;
        end
    end

    assign c = res;

endmodule