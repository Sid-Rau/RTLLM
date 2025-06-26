module alu (
    input [31:0] a,
    input [31:0] b,
    input [5:0] aluc,
    output [31:0] r,
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

    reg [31:0] res_reg;
    reg carry_reg;
    reg overflow_reg;

    assign r = res_reg;
    assign zero = (res_reg == 32'b0) ? 1'b1 : 1'b0;
    assign carry = carry_reg;
    assign negative = res_reg[31];
    assign overflow = overflow_reg;
    assign flag = ((aluc == SLT) || (aluc == SLTU)) ? res_reg[0] : 1'bz;

    always @(*) begin
        res_reg = 32'bz;
        carry_reg = 1'b0;
        overflow_reg = 1'b0;

        case (aluc)
            ADD: begin
                res_reg = a + b;
                carry_reg = (a[31] == b[31]) && (res_reg[31] != a[31]);
                overflow_reg = (a[31] == b[31]) && (res_reg[31] != a[31]);
            end
            ADDU: begin
                res_reg = a + b;
                carry_reg = (a[31] == b[31]) && (res_reg[31] != a[31]);
            end
            SUB: begin
                res_reg = a - b;
                carry_reg = (a[31] != b[31]) && (res_reg[31] != a[31]);
                overflow_reg = (a[31] != b[31]) && (res_reg[31] != a[31]);
            end
            SUBU: begin
                res_reg = a - b;
                carry_reg = (a[31] != b[31]) && (res_reg[31] != a[31]);
            end
            AND: begin
                res_reg = a & b;
            end
            OR: begin
                res_reg = a | b;
            end
            XOR: begin
                res_reg = a ^ b;
            end
            NOR: begin
                res_reg = ~(a | b);
            end
            SLT: begin
                res_reg = ($signed(a) < $signed(b)) ? 32'b1 : 32'b0;
            end
            SLTU: begin
                res_reg = (a < b) ? 32'b1 : 32'b0;
            end
            SLL: begin
                res_reg = b << a[4:0];
            end
            SRL: begin
                res_reg = b >> a[4:0];
            end
            SRA: begin
                res_reg = $signed(b) >>> a[4:0];
            end
            SLLV: begin
                res_reg = b << a;
            end
            SRLV: begin
                res_reg = b >> a;
            end
            SRAV: begin
                res_reg = $signed(b) >>> a;
            end
            LUI: begin
                res_reg = {b[15:0], 16'b0};
            end
            default: begin
                res_reg = 32'bz;
            end
        endcase
    end

endmodule