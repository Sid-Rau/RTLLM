module div_16bit (
    input [15:0] A,
    input [7:0] B,
    output reg [15:0] result,
    output reg [15:0] odd
);
    integer i;
    reg [23:0] dividend;
    reg [7:0] divisor;
    reg [15:0] quotient;
    reg [7:0] remainder;

    always @(*) begin
        dividend = {8'd0, A};
        divisor = B;
        quotient = 16'd0;
        remainder = 8'd0;
        
        for (i = 15; i >= 0; i = i - 1) begin
            remainder = {remainder[6:0], dividend[23]};
            dividend = dividend << 1;
            
            if (remainder >= divisor) begin
                remainder = remainder - divisor;
                quotient[i] = 1'b1;
            end else begin
                quotient[i] = 1'b0;
            end
        end
        
        result = quotient;
        odd = {8'd0, remainder};
    end
endmodule