module float_multi(
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
                3'b000: begin
                    a_sign <= a[31];
                    b_sign <= b[31];
                    a_exponent <= a[30:23];
                    b_exponent <= b[30:23];
                    a_mantissa <= {1'b1, a[22:0]};
                    b_mantissa <= {1'b1, b[22:0]};
                    counter <= counter + 1;
                end
                3'b001: begin
                    if (a_exponent == 255 || b_exponent == 255) begin
                        z <= (a_exponent == 255 && a_mantissa != 0) || (b_exponent == 255 && b_mantissa != 0) ? 32'b01111111100000000000000000000000 : 32'b11111111100000000000000000000000;
                    end else begin
                        z_sign <= a_sign ^ b_sign;
                        z_exponent <= a_exponent + b_exponent - 127;
                        product <= a_mantissa * b_mantissa;
                        counter <= counter + 1;
                    end
                end
                3'b010: begin
                    z_mantissa <= product[47:24];
                    guard_bit <= product[23];
                    round_bit <= product[22];
                    sticky <= |product[21:0];
                    if (z_mantissa[23]) begin
                        z_mantissa <= z_mantissa >> 1;
                        z_exponent <= z_exponent + 1;
                    end
                    counter <= counter + 1;
                end
                3'b011: begin
                    if (guard_bit && (round_bit || sticky)) begin
                        z_mantissa <= z_mantissa + 1;
                    end
                    if (z_mantissa[23]) begin
                        z_mantissa <= z_mantissa >> 1;
                        z_exponent <= z_exponent + 1;
                    end
                    counter <= counter + 1;
                end
                3'b100: begin
                    if (z_exponent >= 255) begin
                        z <= {z_sign, 8'b11111111, 23'b0};
                    end else if (z_exponent <= 0) begin
                        z <= {z_sign, 8'b0, z_mantissa[22:0]};
                    end else begin
                        z <= {z_sign, z_exponent[7:0], z_mantissa[22:0]};
                    end
                    counter <= 3'b000;
                end
            endcase
        end
    end
endmodule