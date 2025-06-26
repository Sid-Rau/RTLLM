module fixed_point_subtractor #(
    parameter Q = 8,
    parameter N = 16
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] c
);

reg [N-1:0] res;

assign c = res;

function [N-1:0] twos_complement;
    input [N-1:0] val;
    twos_complement = ~val + 1;
endfunction

always @(*) begin
    reg [N-1:0] abs_a;
    reg [N-1:0] abs_b;
    reg sign_a; // 0 for positive, 1 for negative
    reg sign_b; // 0 for positive, 1 for negative
    reg sign_res;

    sign_a = a[N-1];
    sign_b = b[N-1];

    if (sign_a) begin // a is negative
        abs_a = twos_complement(a);
    end else begin // a is positive
        abs_a = a;
    end

    if (sign_b) begin // b is negative
        abs_b = twos_complement(b);
    end else begin // b is positive
        abs_b = b;
    end

    if (sign_a == sign_b) begin // Same signs: a - b
        if (abs_a >= abs_b) begin
            res = abs_a - abs_b;
            sign_res = sign_a;
        end else begin
            res = abs_b - abs_a;
            sign_res = ~sign_a;
        end
    end else begin // Different signs: a - (-b) = a + b OR (-a) - b = -(a + b)
        res = abs_a + abs_b;
        if (sign_a == 0) begin // a is positive, b is negative: a - (-b) = a + b
            sign_res = 0; // Result is positive
        end else begin // a is negative, b is positive: (-a) - b = -(a + b)
            sign_res = 1; // Result is negative
        end
    end

    // Apply sign to the result
    if (res == {N{1'b0}}) begin // Handle zero case
        res = {N{1'b0}}; // Ensure positive zero
    end else if (sign_res) begin
        res = twos_complement(res);
    end

end

endmodule