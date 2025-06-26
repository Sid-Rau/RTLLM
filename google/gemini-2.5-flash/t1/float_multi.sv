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
            0: begin // Input Processing and Special Cases
                a_sign <= a[31];
                a_exponent <= a[30:23];
                a_mantissa <= {1'b1, a[22:0]}; // Implicit 1

                b_sign <= b[31];
                b_exponent <= b[30:23];
                b_mantissa <= {1'b1, b[22:0]}; // Implicit 1

                z_sign <= a_sign ^ b_sign;

                // Handle special cases: NaN, Infinity, Zero
                // Check if a is NaN
                if (a_exponent == 8'hFF && a_mantissa[22:0] != 23'h000000) begin
                    z <= a; // Propagate NaN
                    counter <= 0; // Reset for next operation
                // Check if b is NaN
                end else if (b_exponent == 8'hFF && b_mantissa[22:0] != 23'h000000) begin
                    z <= b; // Propagate NaN
                    counter <= 0; // Reset for next operation
                // Check if a is Infinity
                end else if (a_exponent == 8'hFF && a_mantissa[22:0] == 23'h000000) begin
                    // Check if b is Zero
                    if (b_exponent == 8'h00 && b_mantissa[22:0] == 23'h000000) begin
                        z <= 32'h7FC00000; // NaN (Infinity * Zero)
                        counter <= 0;
                    // Check if b is Infinity
                    end else if (b_exponent == 8'hFF && b_mantissa[22:0] == 23'h000000) begin
                        z <= {z_sign, 8'hFF, 23'h000000}; // Infinity * Infinity = Infinity
                        counter <= 0;
                    end else begin // Infinity * Normal/Denormal
                        z <= {z_sign, 8'hFF, 23'h000000}; // Infinity
                        counter <= 0;
                    end
                // Check if b is Infinity
                end else if (b_exponent == 8'hFF && b_mantissa[22:0] == 23'h000000) begin
                    // Check if a is Zero (already handled by a_infinity check)
                    // Check if a is Infinity (already handled by a_infinity check)
                    z <= {z_sign, 8'hFF, 23'h000000}; // Normal/Denormal * Infinity = Infinity
                    counter <= 0;
                // Check if a is Zero
                end else if (a_exponent == 8'h00 && a_mantissa[22:0] == 23'h000000) begin
                    // Check if b is Zero
                    if (b_exponent == 8'h00 && b_mantissa[22:0] == 23'h000000) begin
                        z <= {z_sign, 31'h00000000}; // Zero * Zero = Zero
                        counter <= 0;
                    // Check if b is Infinity (already handled)
                    end else begin // Zero * Normal/Denormal
                        z <= {z_sign, 31'h00000000}; // Zero
                        counter <= 0;
                    end
                // Check if b is Zero
                end else if (b_exponent == 8'h00 && b_mantissa[22:0] == 23'h000000) begin
                    // Check if a is Infinity (already handled)
                    z <= {z_sign, 31'h00000000}; // Normal/Denormal * Zero = Zero
                    counter <= 0;
                end else begin
                    // Handle denormalized inputs
                    if (a_exponent == 8'h00) begin // a is denormal
                        a_mantissa <= {1'b0, a[22:0]}; // No implicit 1
                        a_exponent <= 1; // Treat as if exponent was 1
                    end
                    if (b_exponent == 8'h00) begin // b is denormal
                        b_mantissa <= {1'b0, b[22:0]}; // No implicit 1
                        b_exponent <= 1; // Treat as if exponent was 1
                    end
                    counter <= counter + 1;
                end
            end
            1: begin // Multiplication
                product <= a_mantissa * b_mantissa;
                z_exponent <= a_exponent + b_exponent - 127; // Initial exponent calculation
                counter <= counter + 1;
            end
            2: begin // Normalization and Rounding Setup
                if (product[47]) begin // Product is 2.something (e.g., 1.something * 1.something)
                    z_mantissa <= product[47:24]; // Keep 24 bits
                    z_exponent <= z_exponent + 1;
                    guard_bit <= product[23];
                    round_bit <= product[22];
                    sticky <= |product[21:0];
                end else begin // Product is 1.something (e.g., 1.something * 0.something)
                    z_mantissa <= product[46:23]; // Keep 24 bits
                    guard_bit <= product[22];
                    round_bit <= product[21];
                    sticky <= |product[20:0];
                end
                counter <= counter + 1;
            end
            3: begin // Rounding
                if (guard_bit && (round_bit || sticky || z_mantissa[0])) begin // Round half up to even
                    z_mantissa <= z_mantissa + 1;
                end

                // Check for mantissa overflow after rounding (e.g., 1.11...11 + 1 = 10.00...00)
                if (z_mantissa[24]) begin // If mantissa overflowed (became 2.0)
                    z_mantissa <= z_mantissa >> 1; // Shift right to make it 1.0
                    z_exponent <= z_exponent + 1; // Increment exponent
                end

                // Handle exponent overflow/underflow
                if (z_exponent >= 8'hFF) begin // Exponent overflow (Infinity)
                    z <= {z_sign, 8'hFF, 23'h000000};
                end else if (z_exponent <= 0) begin // Exponent underflow (Denormal or Zero)
                    // Denormalization
                    if (z_exponent == 0) begin // If exponent is 0, result is 1.something * 2^-127
                        // This means it's a denormal if we shift the mantissa
                        z_mantissa <= z_mantissa >> 1; // Shift to make it 0.1something
                        z_exponent <= 0;
                    end else begin // Exponent is negative, need to shift more
                        // Shift right by (1 - z_exponent) to denormalize
                        // Example: z_exponent = -1 -> shift by 2
                        // z_exponent = -126 -> shift by 127
                        // z_exponent = -127 -> shift by 128
                        if (1 - z_exponent < 25) begin // Prevent excessive shifts
                            z_mantissa <= z_mantissa >> (1 - z_exponent);
                        end else begin
                            z_mantissa <= 0; // Very small, becomes zero
                        end
                        z_exponent <= 0; // Exponent becomes 0 for denormals/zero
                    end

                    if (z_mantissa == 0) begin // If denormalized to zero
                        z <= {z_sign, 31'h00000000};
                    end else begin // Denormalized number
                        z <= {z_sign, 8'h00, z_mantissa[22:0]};
                    end
                end else begin // Normal number
                    z <= {z_sign, z_exponent[7:0], z_mantissa[22:0]};
                end
                counter <= 0; // Operation complete, reset counter
            end
            default: begin
                counter <= 0;
            end
        endcase
    end
end

endmodule