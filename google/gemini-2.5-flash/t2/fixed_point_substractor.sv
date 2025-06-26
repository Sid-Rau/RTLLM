module fixed_point_subtractor #(
    parameter Q = 8,
    parameter N = 16
) (
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output wire [N-1:0] c
);

reg [N-1:0] res;

assign c = res;

always @(*) begin
    reg [N-1:0] abs_a;
    reg [N-1:0] abs_b;
    reg [N-1:0] temp_res;
    reg sign_a;
    reg sign_b;
    reg result_sign;

    sign_a = a[N-1];
    sign_b = b[N-1];

    // Calculate absolute values
    if (sign_a) begin // a is negative
        abs_a = ~a + 1;
    end else begin
        abs_a = a;
    end

    if (sign_b) begin // b is negative
        abs_b = ~b + 1;
    end else begin
        abs_b = b;
    end

    if (sign_a == sign_b) begin // Same signs: A - B = A + (-B)
        // This is equivalent to subtracting absolute values and assigning the sign of a
        // Or, if (a - b) is negative, flip the sign
        temp_res = a - b;
        if (temp_res == 0) begin
            result_sign = 0; // Handle zero case
        end else begin
            result_sign = temp_res[N-1];
        end
        res = temp_res;
    end else begin // Different signs: A - B = A + |B|
        // If sign_a is 0 (positive) and sign_b is 1 (negative): a - (-b) = a + |b|
        // If sign_a is 1 (negative) and sign_b is 0 (positive): (-a) - b = -(a + b)
        temp_res = abs_a + abs_b;

        if (sign_a == 0 && sign_b == 1) begin // a is positive, b is negative: a - (-b) = a + |b|
            result_sign = 0; // Result is positive
            res = temp_res;
        end else begin // a is negative, b is positive: (-a) - b = -( |a| + b)
            result_sign = 1; // Result is negative
            res = ~temp_res + 1;
        end

        // Special handling for zero result when signs are different (e.g., 5 - (-5) = 10, not 0)
        // This branch implies addition of absolute values, so result cannot be 0 unless inputs were 0
        if (temp_res == 0) begin // This case should only happen if abs_a and abs_b are both 0
            result_sign = 0;
            res = 0;
        end
    end

    // Final check for zero result to ensure sign bit is 0
    if (res == 0) begin
        res = {1'b0, {(N-1){1'b0}}};
    end
end

endmodule