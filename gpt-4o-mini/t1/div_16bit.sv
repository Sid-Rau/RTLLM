module div_16bit (
    input [15:0] A,
    input [7:0] B,
    output reg [15:0] result,
    output reg [15:0] odd
);
    reg [15:0] a_reg;
    reg [7:0] b_reg;
    reg [15:0] remainder;
    integer i;

    always @* begin
        a_reg = A;
        b_reg = B;
        remainder = a_reg;
        result = 0;

        for (i = 15; i >= 8; i = i - 1) begin
            remainder = {remainder[14:0], remainder[i]};
            if (remainder[15:8] >= b_reg) begin
                remainder[15:8] = remainder[15:8] - b_reg;
                result[i] = 1;
            end
        end
        odd = remainder;
    end
endmodule