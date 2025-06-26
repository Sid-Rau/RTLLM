module alu(
    input [31:0] a,
    input [31:0] b,
    input [5:0] aluc,
    output reg [31:0] r,
    output zero,
    output carry,
    output negative,
    output overflow,
    output flag
);

    parameter ADD = 6'b100000;
    parameter ADDU = 6'b100001;
    parameter SUB = 6'b100010;
    parameter SUBU = 6'b100011;
    parameter AND = 6'b100100;
    parameter OR = 6'b100101;
    parameter XOR = 6'b100110;
    parameter NOR = 6'b100111;
    parameter SLT = 6'b101010;
    parameter SLTU = 6'b101011;
    parameter SLL = 6'b000000;
    parameter SRL = 6'b000010;
    parameter SRA = 6'b000011;
    parameter SLLV = 6'b000100;
    parameter SRLV = 6'b000110;
    parameter SRAV = 6'b000111;
    parameter LUI = 6'b001111;

    wire signed [31:0] sa = a;
    wire signed [31:0] sb = b;
    reg [32:0] res;
    reg flag_reg;
    reg overflow_reg;
    reg carry_reg;

    assign zero = (r == 32'b0);
    assign negative = r[31];
    assign overflow = overflow_reg;
    assign carry = carry_reg;
    assign flag = flag_reg;

    always @(*) begin
        res = 33'b0;
        flag_reg = 1'bz;
        overflow_reg = 1'b0;
        carry_reg = 1'b0;

        case (aluc)
            ADD: begin
                res = sa + sb;
                overflow_reg = (sa[31] == sb[31] && res[31] != sa[31]);
                carry_reg = res[32];
            end
            ADDU: begin
                res = a + b;
                carry_reg = res[32];
            end
            SUB: begin
                res = sa - sb;
                overflow_reg = (sa[31] != sb[31] && res[31] != sa[31]);
                carry_reg = res[32];
            end
            SUBU: begin
                res = a - b;
                carry_reg = res[32];
            end
            AND: res = a & b;
            OR: res = a | b;
            XOR: res = a ^ b;
            NOR: res = ~(a | b);
            SLT: begin
                flag_reg = (sa < sb);
                res = (sa < sb) ? 32'b1 : 32'b0;
            end
            SLTU: begin
                flag_reg = (a < b);
                res = (a < b) ? 32'b1 : 32'b0;
            end
            SLL: res = b << a;
            SRL: res = b >> a;
            SRA: res = sb >>> a;
            SLLV: res = b << a[4:0];
            SRLV: res = b >> a[4:0];
            SRAV: res = sb >>> a[4:0];
            LUI: res = {b[15:0], 16'b0};
            default: res = 33'bz;
        endcase
    end

    always @(*) begin
        r = res[31:0];
    end

endmodule