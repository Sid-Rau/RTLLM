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

                z_sign <= a_sign ^ b_sign;
                counter <= 3'b001;
            end
            3'b001: begin // Stage 1: Special cases and preliminary exponent
                // Check for NaN or Infinity
                if ((a_exponent == 8'hFF && a_mantissa[22:0] != 0) || (b_exponent == 8'hFF && b_mantissa[22:0] != 0)) begin // NaN
                    z <= 32'h7FC00000; // Quiet NaN
                end else if ((a_exponent == 8'hFF && a_mantissa[22:0] == 0) && (b_exponent == 8'h00 && b_mantissa[22:0] == 0)) begin // Inf * 0
                    z <= 32'h7FC00000; // Quiet NaN
                end else if ((b_exponent == 8'hFF && b_mantissa[22:0] == 0) && (a_exponent == 8'h00 && a_mantissa[22:0] == 0)) begin // 0 * Inf
                    z <= 32'h7FC00000; // Quiet NaN
                end else if ((a_exponent == 8'hFF && a_mantissa[22:0] == 0) || (b_exponent == 8'hFF && b_mantissa[22:0] == 0)) begin // Infinity * (non-zero) or Infinity * Infinity
                    z <= {z_sign, 8'hFF, 23'b0}; // Infinity
                end else if ((a_exponent == 8'h00 && a_mantissa[22:0] == 0) || (b_exponent == 8'h00 && b_mantissa[22:0] == 0)) begin // Zero
                    z <= {z_sign, 31'b0}; // Zero
                end else begin
                    // Denormalized numbers handling (simplified: treat as normal for multiplication, then re-normalize)
                    // If a_exponent is 0 and a_mantissa[23] is 1, it's a denormalized number. Remove implicit 1.
                    if (a_exponent == 8'h00) a_mantissa <= {1'b0, a[22:0]};
                    if (b_exponent == 8'h00) b_mantissa <= {1'b0, b[22:0]};

                    // Calculate preliminary exponent
                    z_exponent <= a_exponent + b_exponent - 8'h7F; // Bias adjustment
                    product <= a_mantissa * b_mantissa; // 24x24 -> 48-bit product
                    counter <= 3'b010;
                end
            end
            3'b010: begin // Stage 2: Normalize product and adjust exponent
                if (product[47] == 1'b1) begin // Product is 1.xxxx * 2^E (normalized)
                    z_mantissa <= product[46:23];
                    guard_bit <= product[22];
                    round_bit <= product[21];
                    sticky <= |product[20:0];
                end else begin // Product is 0.1xxx * 2^E (need to shift left by 1)
                    z_mantissa <= product[45:22];
                    guard_bit <= product[21];
                    round_bit <= product[20];
                    sticky <= |product[19:0];
                    z_exponent <= z_exponent - 1; // Decrement exponent for left shift
                end
                counter <= 3'b011;
            end
            3'b011: begin // Stage 3: Rounding
                if (guard_bit && (round_bit || sticky || z_mantissa[0])) begin // Round up
                    z_mantissa <= z_mantissa + 1;
                    if (z_mantissa == 24'h007FFFFF) begin // Mantissa overflow (e.g., 1.11...11 + 1ulp)
                        z_mantissa <= 24'h00800000; // Becomes 1.00...00, effectively shifting up
                        z_exponent <= z_exponent + 1;
                    end
                end
                counter <= 3'b100;
            end
            3'b100: begin // Stage 4: Final assembly and overflow/underflow
                if (z_exponent >= 8'hFF) begin // Overflow
                    z <= {z_sign, 8'hFF, 23'b0}; // Infinity
                end else if (z_exponent <= 8'h00) begin // Underflow or Denormalized
                    // Simple flush to zero for now, more complex denormal handling needed for full compliance
                    z <= {z_sign, 31'b0};
                end else begin
                    z <= {z_sign, z_exponent[7:0], z_mantissa[22:0]};
                end
                counter <= 3'b000; // Reset for next operation
            end
            default: begin
                counter <= 3'b000;
            end
        endcase
    end
end

endmodule