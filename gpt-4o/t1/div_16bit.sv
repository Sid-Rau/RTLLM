module div_16bit(
    input [15:0] A,
    input [7:0] B,
    output reg [15:0] result,
    output reg [15:0] odd
);
    reg [15:0] a_reg;
    reg [7:0] b_reg;
    reg [7:0] temp_dividend;
    reg [7:0] temp_remainder;
    integer i;

    always @* begin
        a_reg = A;
        b_reg = B;
        result = 16'b0;
        temp_remainder = 8'b0;

        for (i = 15; i >= 0; i = i - 1) begin
            temp_dividend = {temp_remainder[6:0], a_reg[i]};
            if (temp_dividend >= b_reg) begin
                temp_remainder = temp_dividend - b_reg;
                result[i] = 1'b1;
            end else begin
                temp_remainder = temp_dividend;
                result[i] = 1'b0;
            end
        end
        odd = {8'b0, temp_remainder};
    end
endmodule