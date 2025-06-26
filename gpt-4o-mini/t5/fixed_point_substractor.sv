module fixed_point_subtractor #(parameter Q = 16, parameter N = 32) (
    input [N-1:0] a,
    input [N-1:0] b,
    output reg [N-1:0] c
);
    reg [N-1:0] res;

    always @(*) begin
        if (a[N-1] == b[N-1]) begin
            // Same sign subtraction
            res = a - b;
            if (res == 0) begin
                c = 0;
            end else begin
                c = res;
            end
        end else begin
            // Different sign subtraction
            if (a[N-1] == 0 && b[N-1] == 1) begin
                // a positive, b negative
                if (a > {1'b0, b[N-2:0]}) begin
                    c = a + {1'b0, b[N-2:0]};
                end else begin
                    c = ~(b) + 1;
                end
            end else if (a[N-1] == 1 && b[N-1] == 0) begin
                // a negative, b positive
                if ({1'b0, a[N-2:0]} > b) begin
                    c = ~(b) + 1;
                end else begin
                    c = b + {1'b0, a[N-2:0]};
                end
            end
        end
    end
endmodule