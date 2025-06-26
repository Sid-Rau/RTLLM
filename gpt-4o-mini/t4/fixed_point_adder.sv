module fixed_point_adder #(parameter Q = 16, parameter N = 32) (
    input  [N-1:0] a,
    input  [N-1:0] b,
    output [N-1:0] c
);
    reg [N-1:0] res;

    always @* begin
        if (a[N-1] == b[N-1]) begin
            res = a + b;
            res[N-1] = a[N-1]; // Keep the sign bit
        end else begin
            if (a > b) begin
                res = a - b;
                res[N-1] = 0; // Positive result
            end else begin
                res = b - a;
                res[N-1] = (res == 0) ? 0 : 1; // Set sign bit based on result
            end
        end
    end

    assign c = res;
endmodule