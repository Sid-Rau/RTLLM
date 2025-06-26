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
            3'b000: begin // Stage 0: Extract components
                a_sign <= a[31];
                a_exponent <= a[30:23];
                a_mantissa <= {1'b1, a[22:0]}; // Add implicit leading 1
                
                b_sign <= b[31];
                b_exponent <= b[30:23];
                b_mantissa <= {1'b1, b[22:0]}; // Add implicit leading 1

                // Handle special cases: NaN, Infinity, Zero
                // If a is NaN or b is NaN, result is NaN
                if ((a_exponent == 8'hFF && a[22:0] != 23'b0) || (b_exponent == 8'hFF && b[22:0] != 23'b0)) begin
                    z <= 32'h7FC00000; // QNaN
                end 
                // If a is Infinity or b is Infinity
                else if (a_exponent == 8'hFF || b_exponent == 8'hFF) begin
                    // If either is zero, result is NaN
                    if ((a_exponent == 8'hFF && a[22:0] == 23'b0 && b_exponent == 8'h00 && b[22:0] == 23'b0) ||
                        (b_exponent == 8'hFF && b[22:0] == 23'b0 && a_exponent == 8'h00 && a[22:0] == 23'b0)) begin
                        z <= 32'h7FC00000; // NaN
                    end
                    // Otherwise, result is Infinity
                    else begin
                        z_sign <= a_sign ^ b_sign;
                        z <= {z_sign, 8'hFF, 23'b0}; // Infinity
                    end
                end
                // If either is zero, result is zero
                else if ((a_exponent == 8'h00 && a[22:0] == 23'b0) || (b_exponent == 8'h00 && b[22:0] == 23'b0)) begin
                    z_sign <= a_sign ^ b_sign;
                    z <= {z_sign, 31'b0}; // Zero
                end
                else begin
                    counter <= 3'b001;
                end
            end

            3'b001: begin // Stage 1: Mantissa Multiplication and Exponent Addition
                z_sign <= a_sign ^ b_sign;
                product <= a_mantissa * b_mantissa;
                z_exponent <= a_exponent + b_exponent - 127; // Bias adjustment
                counter <= 3'b010;
            end

            3'b010: begin // Stage 2: Normalization and Rounding Prep
                guard_bit <= product[24];
                round_bit <= product[23];
                sticky <= |product[22:0];

                if (product[47]) begin // Product is 2.something (e.g., 1.something * 1.something = 1.something or 2.something)
                    z_mantissa <= product[47:24]; // Shift right by 1
                    z_exponent <= z_exponent + 1;
                end else begin // Product is 1.something
                    z_mantissa <= product[46:23]; // Keep as is
                end
                counter <= 3'b011;
            end

            3'b011: begin // Stage 3: Rounding
                // Round to nearest even
                if (guard_bit) begin
                    if (round_bit || sticky || z_mantissa[0]) begin // Round up if round_bit or sticky is set, or if mantissa is odd
                        z_mantissa <= z_mantissa + 1;
                    end
                end
                counter <= 3'b100;
            end

            3'b100: begin // Stage 4: Final Assembly and Overflow/Underflow Check
                // Check for overflow
                if (z_exponent >= 8'hFF) begin
                    z <= {z_sign, 8'hFF, 23'b0}; // Infinity
                end
                // Check for underflow (denormal or zero)
                else if (z_exponent <= 8'h00) begin
                    z <= {z_sign, 31'b0}; // Zero (for now, could be denormalized)
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