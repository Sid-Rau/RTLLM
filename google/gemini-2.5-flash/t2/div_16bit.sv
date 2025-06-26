module div_16bit (
    input  [15:0] A,
    input  [7:0]  B,
    output [15:0] result,
    output [15:0] odd
);

reg [15:0] a_reg;
reg [7:0]  b_reg;

reg [15:0] quotient;
reg [15:0] remainder;

always @(*) begin
    a_reg = A;
    b_reg = B;
end

always @(*) begin
    reg [15:0] current_remainder;
    reg [15:0] current_quotient;
    integer i;

    current_quotient = 16'b0;
    current_remainder = 16'b0;

    // Initialize the first 8 bits of current_remainder with the MSBs of A
    current_remainder[7:0] = a_reg[15:8];

    for (i = 0; i < 16; i = i + 1) begin
        if (current_remainder[7:0] >= b_reg) begin
            current_quotient = (current_quotient << 1) | 1'b1;
            current_remainder[7:0] = current_remainder[7:0] - b_reg;
        end else begin
            current_quotient = (current_quotient << 1) | 1'b0;
        end

        // Shift the remainder left and bring in the next bit from A
        if (i < 15) begin
            current_remainder = (current_remainder << 1) | a_reg[15 - (i + 1)];
        end
    end

    quotient = current_quotient;
    remainder = current_remainder;
end

assign result = quotient;
assign odd = remainder;

endmodule