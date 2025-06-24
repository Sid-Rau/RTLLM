module div_16bit(
    input [15:0] A,
    input [7:0] B,
    output reg [15:0] result,
    output reg [15:0] odd
);
    reg [15:0] dividend;
    reg [7:0] divisor;
    reg [15:0] quotient;
    reg [15:0] remainder;
    integer i;

    always @(*) begin
        dividend = A;
        divisor = B;
        quotient = 16'b0;
        remainder = 16'b0;

        for (i = 15; i >= 0; i = i - 1) begin
            remainder = {remainder[14:0], dividend[i]};
            if (remainder[15:8] >= divisor) begin
                remainder[15:8] = remainder[15:8] - divisor;
                quotient[i] = 1'b1;
            end
        end

        result = quotient;
        odd = remainder;
    end
endmodule