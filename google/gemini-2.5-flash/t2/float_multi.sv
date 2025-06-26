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
        counter <= 3'b000;
        z <= 32'b0;
    end else begin
        case (counter)
            3'b000: begin // Input Processing and Extraction
                a_sign <= a[31];
                a_exponent <= a[30:23];
                a_mantissa <= {1'b1, a[22:0]}; // Implicit leading 1

                b_sign <= b[31];
                b_exponent <= b[30:23];
                b_mantissa <= {1'b1, b[22:0]}; // Implicit leading 1

                z_sign <= a_sign ^ b_sign;

                // Handle special cases: NaN, Infinity, Zero
                // NaN check (exponent all 1s, mantissa non-zero)
                if ((a_exponent == 8'hFF && a[22:0] != 23'b0) || (b_exponent == 8'hFF && b[22:0] != 23'b0)) begin
                    z <= 32'h7FC00000; // Quiet NaN
                    counter <= 3'b000; // Reset for next operation
                end
                // Infinity check (exponent all 1s, mantissa zero)
                else if ((a_exponent == 8'hFF && a[22:0] == 23'b0) || (b_exponent == 8'hFF && b[22:0] == 23'b0)) begin
                    // Inf * 0 = NaN
                    if (((a_exponent == 8'hFF && a[22:0] == 23'b0) && (b_exponent == 8'h00 && b[22:0] == 23'b0)) ||
                        ((b_exponent == 8'hFF && b[22:0] == 23'b0) && (a_exponent == 8'h00 && a[22:0] == 23'b0))) begin
                        z <= 32'h7FC00000; // NaN
                    end
                    // Inf * Inf or Inf * non-zero finite = Inf
                    else begin
                        z <= {z_sign, 8'hFF, 23'b0}; // Signed Infinity
                    end
                    counter <= 3'b000;
                end
                // Zero check
                else if ((a_exponent == 8'h00 && a[22:0] == 23'b0) || (b_exponent == 8'h00 && b[22:0] == 23'b0)) begin
                    z <= {z_sign, 31'b0}; // Signed Zero
                    counter <= 3'b000;
                end
                else begin
                    counter <= 3'b001;
                end
            end

            3'b001: begin // Mantissa Multiplication and Exponent Addition
                // Denormalized inputs become normalized here
                if (a_exponent == 8'h00) a_mantissa <= {1'b0, a[22:0]}; // Denormal, no implicit 1
                if (b_exponent == 8'h00) b_mantissa <= {1'b0, b[22:0]}; // Denormal, no implicit 1

                product <= a_mantissa * b_mantissa;
                z_exponent <= (a_exponent + b_exponent) - 127; // Exponent bias adjustment

                counter <= 3'b010;
            end

            3'b010: begin // Normalization and Rounding Preparation
                // Check for normalization of product
                if (product[47]) begin // Product is >= 2.0 (e.g., 1.x * 1.x = 1.xx or 2.xx)
                    z_mantissa <= product[47:24]; // Take bits 47 down to 24 (implicit 1 at bit 47)
                    z_exponent <= z_exponent + 1;
                    guard_bit <= product[23];
                    round_bit <= product[22];
                    sticky <= |product[21:0];
                end else begin // Product is < 2.0 (e.g., 1.x * 1.x = 1.xx)
                    z_mantissa <= product[46:23]; // Take bits 46 down to 23 (implicit 1 at bit 46)
                    guard_bit <= product[22];
                    round_bit <= product[21];
                    sticky <= |product[20:0];
                end
                counter <= 3'b011;
            end

            3'b011: begin // Rounding
                reg round_up;
                round_up = 1'b0;

                // Round to nearest, ties to even
                if (guard_bit) begin
                    if (round_bit || sticky) begin
                        round_up = 1'b1;
                    end else begin // Tie case (guard_bit=1, round_bit=0, sticky=0)
                        if (z_mantissa[0]) begin // If LSB of mantissa is 1, round up to make it even
                            round_up = 1'b1;
                        end
                    end
                end

                if (round_up) begin
                    z_mantissa <= z_mantissa + 1;
                    if (z_mantissa == 24'h1000000) begin // Mantissa overflow after rounding (e.g., 1.11...1 + 1 = 10.00...0)
                        z_mantissa <= 24'h800000; // Becomes 1.0 (implicit 1 at bit 23)
                        z_exponent <= z_exponent + 1;
                    end
                end
                counter <= 3'b100;
            end

            3'b100: begin // Final Assembly and Overflow/Underflow
                // Check for exponent overflow (Infinity)
                if (z_exponent >= 8'hFF) begin
                    z <= {z_sign, 8'hFF, 23'b0}; // Infinity
                end
                // Check for exponent underflow (Zero or Denormal)
                else if (z_exponent <= 8'b00) begin
                    // If exponent is too small, result is zero or denormal
                    // For simplicity, we'll clamp to zero for now
                    z <= {z_sign, 31'b0}; // Signed Zero
                end
                else begin
                    z <= {z_sign, z_exponent[7:0], z_mantissa[22:0]};
                end
                counter <= 3'b000; // Reset for next operation
            end
            default: counter <= 3'b000;
        endcase
    end
end

endmodule