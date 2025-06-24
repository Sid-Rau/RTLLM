module fixed_point_adder #(parameter Q = 8, parameter N = 16)(
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output reg [N-1:0] c
);

    reg [N-1:0] res;
    reg [N-2:0] abs_a, abs_b;
    reg sign_a, sign_b;

    always @(*) begin
        sign_a = a[N-1];
        sign_b = b[N-1];
        abs_a = a[N-2:0];
        abs_b = b[N-2:0];
        
        if (sign_a == sign_b) begin
            res = {sign_a, abs_a + abs_b};
        end else begin
            if (abs_a >= abs_b) begin
                res = {sign_a, abs_a - abs_b};
            end else begin
                res = {sign_b, abs_b - abs_a};
            end
        end
        
        c = res;
    end

endmodule