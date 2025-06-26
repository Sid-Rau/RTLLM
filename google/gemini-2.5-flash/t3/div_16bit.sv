module div_16bit (
    input  [15:0] A,
    input  [7:0]  B,
    output [15:0] result,
    output [15:0] odd
);

reg [15:0] a_reg;
reg [7:0]  b_reg;

reg [15:0] q_reg;
reg [15:0] r_reg;

always @(*) begin
    a_reg = A;
    b_reg = B;
end

always @(*) begin
    reg [15:0] current_remainder;
    reg [15:0] current_quotient;
    reg [15:0] temp_dividend;
    reg [7:0]  temp_divisor;

    current_quotient = 16'b0;
    current_remainder = 16'b0;
    temp_dividend = a_reg;
    temp_divisor = b_reg;

    if (temp_divisor == 8'b0) begin
        // Handle division by zero, can set to all 1s or specific error value
        current_quotient = 16'hFFFF;
        current_remainder = 16'hFFFF;
    end else begin
        current_remainder = temp_dividend[15:8]; // Initialize with the highest 8 bits of A

        for (integer i = 15; i >= 0; i = i - 1) begin
            if (i < 8) begin // For the lower bits of the dividend, concatenate remainder with 1 bit
                current_remainder = {current_remainder[14:0], temp_dividend[i]};
            end

            if (current_remainder[7:0] >= temp_divisor) begin
                current_quotient[i] = 1'b1;
                current_remainder = current_remainder - {8'b0, temp_divisor};
            end else begin
                current_quotient[i] = 1'b0;
            end
        end
    end

    q_reg = current_quotient;
    r_reg = current_remainder;
end

assign result = q_reg;
assign odd = r_reg;

endmodule