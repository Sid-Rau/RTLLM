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
            z <= 0;
        end else begin
            case (counter)
                0: begin
                    a_sign <= a[31];
                    b_sign <= b[31];
                    a_exponent <= {2'b0, a[30:23]};
                    b_exponent <= {2'b0, b[30:23]};
                    a_mantissa <= (|a[30:23]) ? {1'b1, a[22:0]} : {1'b0, a[22:0]};
                    b_mantissa <= (|b[30:23]) ? {1'b1, b[22:0]} : {1'b0, b[22:0]};
                    counter <= 1;
                end
                1: begin
                    z_sign <= a_sign ^ b_sign;
                    z_exponent <= a_exponent + b_exponent - 10'd127;
                    product <= a_mantissa * b_mantissa;
                    counter <= 2;
                end
                2: begin
                    if (product[47]) begin
                        z_mantissa <= product[47:24];
                        guard_bit <= product[23];
                        round_bit <= product[22];
                        sticky <= |product[21:0];
                        z_exponent <= z_exponent + 1;
                    end else begin
                        z_mantissa <= product[46:23];
                        guard_bit <= product[22];
                        round_bit <= product[21];
                        sticky <= |product[20:0];
                    end
                    counter <= 3;
                end
                3: begin
                    if (guard_bit && (round_bit || sticky || z_mantissa[0])) begin
                        z_mantissa <= z_mantissa + 1;
                        if (&z_mantissa) begin
                            z_exponent <= z_exponent + 1;
                        end
                    end
                    counter <= 4;
                end
                4: begin
                    if (z_exponent[9] || (z_exponent == 0 && z_mantissa == 0)) begin
                        z <= {z_sign, 31'b0};
                    end else if (z_exponent >= 255) begin
                        z <= {z_sign, 8'hFF, 23'b0};
                    end else begin
                        z <= {z_sign, z_exponent[7:0], z_mantissa[22:0]};
                    end
                    counter <= 0;
                end
            endcase
        end
    end

endmodule