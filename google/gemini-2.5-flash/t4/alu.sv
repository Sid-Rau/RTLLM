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

    reg [31:0] res;
    reg _carry;
    reg _overflow;
    reg _flag;

    assign r = res;
    assign zero = (res == 32'b0);
    assign negative = res[31];
    assign carry = _carry;
    assign overflow = _overflow;
    assign flag = _flag;

    always @(*) begin
        res = 32'bz;
        _carry = 1'b0;
        _overflow = 1'b0;
        _flag = 1'b0;

        case (aluc)
            ADD, SUB: begin
                reg [32:0] sum_sub;
                if (aluc == ADD) begin
                    sum_sub = {1'b0, a} + {1'b0, b};
                end else begin // SUB
                    sum_sub = {1'b0, a} - {1'b0, b};
                end
                res = sum_sub[31:0];
                _carry = sum_sub[32];
                _overflow = ((a[31] == b[31]) && (a[31] != res[31])) && (aluc == ADD);
                _overflow = _overflow || ((a[31] != b[31]) && (b[31] == res[31])) && (aluc == SUB);
            end
            ADDU, SUBU: begin
                if (aluc == ADDU) begin
                    res = a + b;
                    _carry = (a + b) < a; // Check for unsigned carry
                end else begin // SUBU
                    res = a - b;
                    _carry = (a - b) > a; // Check for unsigned borrow (carry)
                end
            end
            AND: res = a & b;
            OR: res = a | b;
            XOR: res = a ^ b;
            NOR: res = ~(a | b);
            SLT: begin
                _flag = 1'b1;
                res = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            end
            SLTU: begin
                _flag = 1'b1;
                res = (a < b) ? 32'd1 : 32'd0;
            end
            SLL: res = b << a[4:0];
            SRL: res = b >> a[4:0];
            SRA: res = $signed(b) >>> a[4:0];
            SLLV: res = b << a;
            SRLV: res = b >> a;
            SRAV: res = $signed(b) >>> a;
            LUI: res = {b[15:0], 16'b0};
            default: begin
                res = 32'bz;
                _carry = 1'bz;
                _overflow = 1'bz;
                _flag = 1'bz;
            end
        endcase
    end

endmodule