module float_multi(
    input clk,
    input rst,
    input [31:0] a,
    input [31:0] b,
    output reg [31:0] z
);
    reg [2:0] counter;
    reg [23:0] a_mantissa, b_mantissa, z_mantissa;
    reg [8:0] a_exponent, b_exponent, z_exponent;
    reg a_sign, b_sign, z_sign;
    reg [49:0] product;
    reg guard_bit, round_bit, sticky;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
            z <= 32'b0;
        end else begin
            case (counter)
                3'd0: begin
                    a_sign <= a[31];
                    b_sign <= b[31];
                    a_exponent <= a[30:23] - 127;
                    b_exponent <= b[30:23] - 127;
                    a_mantissa <= {1'b1, a[22:0]};
                    b_mantissa <= {1'b1, b[22:0]};
                    counter <= counter + 1;
                end
                3'd1: begin
                    if (a_exponent == 255 || b_exponent == 255) begin
                        z <= (a_exponent == 255 && a[22:0] != 0) || (b_exponent == 255 && b[22:0] != 0) ? 32'h7FFFFFFF : 32'h7F800000;
                    end else begin
                        product <= a_mantissa * b_mantissa;
                        z_sign <= a_sign ^ b_sign;
                        z_exponent <= a_exponent + b_exponent + 127;
                        counter <= counter + 1;
                    end
                end
                3'd2: begin
                    if (product[47]) begin
                        z_mantissa <= product[46:24];
                        z_exponent <= z_exponent + 1;
                    end else begin
                        z_mantissa <= product[45:23];
                    end
                    counter <= counter + 1;
                end
                3'd3: begin
                    guard_bit <= product[23];
                    round_bit <= product[22];
                    sticky <= |product[21:0];
                    if (round_bit && (guard_bit || sticky)) begin
                        z_mantissa <= z_mantissa + 1;
                    end
                    z <= {z_sign, z_exponent[7:0], z_mantissa[22:0]};
                    counter <= 0;
                end
            endcase
        end
    end
endmodule