module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [5:0] aluc,
    output reg [31:0] r,
    output zero,
    output carry,
    output negative,
    output overflow,
    output reg flag
);
    wire signed [31:0] a_signed = a;
    wire signed [31:0] b_signed = b;
    wire [32:0] add_result = a + b;
    wire [32:0] sub_result = a - b;
    
    assign zero = (r == 32'b0);
    assign carry = add_result[32];
    assign negative = r[31];
    assign overflow = (aluc == ADD || aluc == SUB) ? (add_result[31] ^ a[31] ^ b[31] ^ r[31]) : 1'b0;

    always @(*) begin
        case (aluc)
            6'b100000: r = add_result[31:0]; flag = 1'b0; // ADD
            6'b100001: r = a + b; flag = 1'b0; // ADDU
            6'b100010: r = sub_result[31:0]; flag = 1'b0; // SUB
            6'b100011: r = a - b; flag = 1'b0; // SUBU
            6'b100100: r = a & b; flag = 1'b0; // AND
            6'b100101: r = a | b; flag = 1'b0; // OR
            6'b100110: r = a ^ b; flag = 1'b0; // XOR
            6'b100111: r = ~(a | b); flag = 1'b0; // NOR
            6'b101010: r = (a_signed < b_signed) ? 32'b1 : 32'b0; flag = 1'b1; // SLT
            6'b101011: r = (a < b) ? 32'b1 : 32'b0; flag = 1'b1; // SLTU
            6'b000000: r = b << a[4:0]; flag = 1'b0; // SLL
            6'b000010: r = b >> a[4:0]; flag = 1'b0; // SRL
            6'b000011: r = $signed(b) >>> a[4:0]; flag = 1'b0; // SRA
            6'b000100: r = b << a_signed; flag = 1'b0; // SLLV
            6'b000110: r = b >> a_signed; flag = 1'b0; // SRLV
            6'b000111: r = $signed(b) >>> a_signed; flag = 1'b0; // SRAV
            6'b001111: r = {a[15:0], 16'b0}; flag = 1'b0; // LUI
            default: r = 32'bz; flag = 1'bz; // Default case
        endcase
    end
endmodule