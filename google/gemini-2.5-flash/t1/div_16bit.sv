module div_16bit (
    input  [15:0] A,
    input  [7:0]  B,
    output [15:0] result,
    output [15:0] odd
);

reg [15:0] quotient_reg;
reg [15:0] remainder_reg;
reg [15:0] dividend_reg;
reg [7:0]  divisor_reg;

always @(*) begin
    dividend_reg = A;
    divisor_reg = B;
end

always @(*) begin
    reg [15:0] current_quotient;
    reg [15:0] current_remainder;
    reg [15:0] temp_dividend;
    reg [7:0] temp_divisor;
    integer i;

    current_quotient = 16'h0000;
    current_remainder = 16'h0000;
    temp_dividend = dividend_reg;
    temp_divisor = divisor_reg;

    // Handle division by zero
    if (temp_divisor == 8'h00) begin
        current_quotient = 16'hFFFF; // Indicate error/overflow
        current_remainder = 16'hFFFF; // Indicate error/overflow
    end else begin
        for (i = 15; i >= 0; i = i - 1) begin
            current_remainder = current_remainder << 1;
            current_remainder[0] = temp_dividend[i];

            if (current_remainder[7:0] >= temp_divisor) begin
                current_remainder = current_remainder - {8'h00, temp_divisor};
                current_quotient[i] = 1'b1;
            end else begin
                current_quotient[i] = 1'b0;
            end
        end
    end

    quotient_reg = current_quotient;
    remainder_reg = current_remainder;
end

assign result = quotient_reg;
assign odd = remainder_reg;

endmodule