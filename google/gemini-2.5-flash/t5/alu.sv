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

    reg [32:0] res;
    wire signed [31:0] signed_a;
    wire signed [31:0] signed_b;
    wire signed [32:0] signed_res;

    assign signed_a = a;
    assign signed_b = b;
    assign signed_res = res;

    assign r = res[31:0];
    assign zero = (r == 32'b0);
    assign negative = r[31];

    assign flag = ((aluc == SLT) || (aluc == SLTU)) ? r[0] : 1'bz;

    assign carry = ((aluc == ADDU) || (aluc == ADD)) ? res[32] :
                   ((aluc == SUBU) || (aluc == SUB)) ? ~res[32] : 1'bz;

    assign overflow = ((aluc == ADD) || (aluc == SUB)) ?
                      ((signed_a[31] == signed_b[31]) && (signed_a[31] != signed_res[31])) : 1'bz;

    always @(*) begin
        res = 33'bz; // Default to high-impedance
        case (aluc)
            ADD: begin
                res = {1'b0, a} + {1'b0, b};
            end
            ADDU: begin
                res = {1'b0, a} + {1'b0, b};
            end
            SUB: begin
                res = {1'b0, a} - {1'b0, b};
            end
            SUBU: begin
                res = {1'b0, a} - {1'b0, b};
            end
            AND: begin
                res = {1'b0, a & b};
            end
            OR: begin
                res = {1'b0, a | b};
            end
            XOR: begin
                res = {1'b0, a ^ b};
            end
            NOR: begin
                res = {1'b0, ~(a | b)};
            end
            SLT: begin
                res = {32'b0, (signed_a < signed_b)};
            end
            SLTU: begin
                res = {32'b0, (a < b)};
            end
            SLL: begin
                res = {1'b0, b << a[4:0]};
            end
            SRL: begin
                res = {1'b0, b >> a[4:0]};
            end
            SRA: begin
                res = {1'b0, ($signed(b) >>> a[4:0])};
            end
            SLLV: begin
                res = {1'b0, b << a};
            end
            SRLV: begin
                res = {1'b0, b >> a};
            end
            SRAV: begin
                res = {1'b0, ($signed(b) >>> a)};
            end
            LUI: begin
                res = {1'b0, b << 16};
            end
            default: begin
                res = 33'bz;
            end
        endcase
    end

endmodule