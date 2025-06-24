module div_16bit (
    input  [15:0] A,
    input  [7:0]  B,
    output reg [15:0] result,
    output reg [15:0] odd
);
    reg [15:0] a_reg;
    reg [7:0]  b_reg;

    always @* begin
        a_reg = A;
        b_reg = B;
        result = 0;
        odd = 0;
        for (integer i = 15; i >= 0; i = i - 1) begin
            odd = {odd[14:0], a_reg[15]};
            a_reg = a_reg << 1;
            if (odd >= {8'b0, b_reg}) begin
                odd = odd - {8'b0, b_reg};
                result[i] = 1;
            end
        end
    end
endmodule