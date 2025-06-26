module div_16bit(
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
        remainder = 0;
        result = 0;

        for (i = 15; i >= 8; i = i - 1) begin
            remainder = {remainder[14:0], a_reg[i]};
            if (remainder >= b_reg) begin
                remainder = remainder - b_reg;
                result[i] = 1;
            end else begin
                result[i] = 0;
            end
        end

        for (i = 7; i >= 0; i = i - 1) begin
            remainder = {remainder[14:0], a_reg[i]};
            if (remainder >= b_reg) begin
                remainder = remainder - b_reg;
                result[i] = 1;
            end else begin
                result[i] = 0;
            end
        end
        
        odd = remainder;
    end
endmodule