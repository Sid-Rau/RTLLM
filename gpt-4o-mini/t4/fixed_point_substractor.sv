module fixed_point_subtractor #(parameter Q = 16, parameter N = 32) (
    input  [N-1:0] a,
    input  [N-1:0] b,
    output [N-1:0] c
);
    reg [N-1:0] res;

    always @* begin
        if (a[N-1] == b[N-1]) begin
            // Same sign subtraction
            res = a - b;
            if (res == 0) begin
                res[N-1] = 0; // Set sign bit to 0 if result is zero
            end else begin
                res[N-1] = a[N-1]; // Keep the sign of the result same as input
            end
        end else begin
            // Different sign subtraction
            if (a[N-1] == 0 && b[N-1] == 1) begin
                // a positive, b negative
                res = a + {1'b0, b[N-2:0]};
                res[N-1] = (a >= {1'b0, b[N-2:0]}) ? 0 : 1;
            end else if (a[N-1] == 1 && b[N-1] == 0) begin
                // a negative, b positive
                res = {1'b0, a[N-2:0]} + b;
                res[N-1] = (b >= {1'b0, a[N-2:0]}) ? 1 : 0;
            end
        end
    end

    assign c = res;
endmodule