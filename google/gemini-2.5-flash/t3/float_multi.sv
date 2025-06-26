module float_multi (
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] z
);

reg [2:0] counter;
reg [23:0] a_mantissa, b_mantissa, z_mantissa;
reg [9:0] a_exponent, b_exponent, z_exponent;
reg a_sign, b_sign, z_sign;
reg [49:0] product;
reg guard_bit, round_bit, sticky;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 0;
        z <= 32'h00000000;
    end else begin
        case (counter)
            0: begin // Extract inputs and handle special cases
                a_sign <= a[31];
                a_exponent <= a[30:23];
                a_mantissa <= {1'b1, a[22:0]}; // Implicit leading 1

                b_sign <= b[31];
                b_exponent <= b[30:23];
                b_mantissa <= {1'b1, b[22:0]}; // Implicit leading 1

                z_sign <= a_sign ^ b_sign;

                // Handle NaN and Infinity
                if ((a_exponent == 8'hFF && a_mantissa[22:0] != 23'h000000) ||
                    (b_exponent == 8'hFF && b_mantissa[22:0] != 23'h000000)) begin // NaN
                    z <= 32'h7FC00000; // Quiet NaN
                end else if ((a_exponent == 8'hFF && a_mantissa[22:0] == 23'h000000) ||
                           (b_exponent == 8'hFF && b_mantissa[22:0] == 23'h000000)) begin // Infinity
                    if ((a_exponent == 8'hFF && a_mantissa[22:0] == 23'h000000) &&
                        (b_exponent == 8'hFF && b_mantissa[22:0] == 23'h000000)) begin // Inf * Inf
                        z <= {z_sign, 8'hFF, 23'h000000};
                    end else if (((a_exponent == 8'hFF && a_mantissa[22:0] == 23'h000000) && (b_exponent == 8'h00 && b_mantissa[22:0] == 23'h000000)) ||
                               ((b_exponent == 8'hFF && b_mantissa[22:0] == 23'h000000) && (a_exponent == 8'h00 && a_mantissa[22:0] == 23'h000000))) begin // Inf * 0
                        z <= 32'h7FC00000; // Quiet NaN
                    end else begin // Inf * normal/denormal
                        z <= {z_sign, 8'hFF, 23'h000000};
                    end
                end else if ((a_exponent == 8'h00 && a_mantissa[22:0] == 23'h000000) ||
                           (b_exponent == 8'h00 && b_mantissa[22:0] == 23'h000000)) begin // Zero
                    z <= {z_sign, 31'h00000000};
                end else begin
                    counter <= counter + 1;
                end
            end
            1: begin // Mantissa multiplication and exponent addition
                // Handle denormalized inputs by adjusting mantissa and exponent
                if (a_exponent == 8'h00) begin // a is denormal
                    a_mantissa <= {1'b0, a[22:0]}; // No implicit 1 for denormals
                    a_exponent <= 1; // Effective exponent for denormal
                end
                if (b_exponent == 8'h00) begin // b is denormal
                    b_mantissa <= {1'b0, b[22:0]}; // No implicit 1 for denormals
                    b_exponent <= 1; // Effective exponent for denormal
                end

                product <= a_mantissa * b_mantissa;
                z_exponent <= a_exponent + b_exponent - 127; // Bias adjustment

                counter <= counter + 1;
            end
            2: begin // Normalization and rounding
                if (product[47]) begin // Product is 2.xxxx (normalized)
                    z_mantissa <= product[47:24];
                    z_exponent <= z_exponent + 1;
                    guard_bit <= product[23];
                    round_bit <= product[22];
                    sticky <= |product[21:0];
                end else begin // Product is 1.xxxx (normalized)
                    z_mantissa <= product[46:23];
                    guard_bit <= product[22];
                    round_bit <= product[21];
                    sticky <= |product[20:0];
                end

                // Round to nearest, ties to even
                if (guard_bit) begin
                    if (round_bit || sticky || z_mantissa[0]) begin
                        z_mantissa <= z_mantissa + 1;
                        if (z_mantissa == 24'h01000000) begin // Overflow after increment (e.g., 1.11...1 -> 10.00...0)
                            z_mantissa <= 24'h00800000; // Becomes 1.00...0
                            z_exponent <= z_exponent + 1;
                        end
                    end
                end
                
                counter <= counter + 1;
            end
            3: begin // Final assembly and overflow/underflow
                if (z_exponent >= 8'hFF) begin // Exponent overflow (Infinity)
                    z <= {z_sign, 8'hFF, 23'h000000};
                end else if (z_exponent <= 0) begin // Exponent underflow (Denormal or Zero)
                    // Denormalization
                    if (z_exponent == 0 && z_mantissa[23] == 1) begin // If mantissa is 1.x and exp becomes 0, it's normal.
                        z <= {z_sign, z_exponent[7:0], z_mantissa[22:0]};
                    end else if (z_exponent < -23) begin // Too small to be denormal
                        z <= {z_sign, 31'h00000000}; // Zero
                    end else begin
                        // Shift mantissa right, decrement exponent until exponent is 0
                        z_mantissa <= z_mantissa >> (1 - z_exponent);
                        z <= {z_sign, 8'h00, z_mantissa[22:0]};
                    end
                end else begin
                    z <= {z_sign, z_exponent[7:0], z_mantissa[22:0]};
                end
                counter <= 0; // Reset for next operation
            end
            default: begin
                counter <= 0;
            end
        endcase
    end
end

endmodule