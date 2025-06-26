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

    if (sign_a == sign_b) begin // Same sign subtraction (a - b)
        if (abs_a >= abs_b) begin
            temp_res = abs_a - abs_b;
            result_sign = sign_a;
        end else begin
            temp_res = abs_b - abs_a;
            result_sign = ~sign_a; // Result sign is opposite of input signs
        end
    end else begin // Different sign subtraction (a - b) which is effectively a + |b|
        temp_res = abs_a + abs_b;
        // Determine result sign based on which original number has larger absolute value
        // If a is positive, b is negative: a - (-|b|) = a + |b|. Result sign is sign of a.
        // If a is negative, b is positive: -|a| - b = -(|a| + b). Result sign is sign of a.
        result_sign = sign_a;
    end

    // Apply sign to the result
    if (temp_res == 0) begin
        res = 0; // Explicitly set sign bit to 0 for zero
    end else if (result_sign) begin // Result is negative
        res = ~temp_res + 1;
    end else begin // Result is positive
        res = temp_res;
    end
end

endmodule