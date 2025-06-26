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
    assign zero = (res_reg == 32'h00000000);
    assign carry = carry_reg;
    assign negative = res_reg[31];
    assign overflow = overflow_reg;
    assign flag = (aluc == SLT || aluc == SLTU) ? res_reg[0] : 1'bz;

    wire signed [31:0] signed_a = a;
    wire signed [31:0] signed_b = b;
    wire [32:0] add_sub_res;

    always @(*) begin
        res_reg = 32'bz;
        carry_reg = 1'b0;
        overflow_reg = 1'b0;

        case (aluc)
            ADD: begin
                add_sub_res = signed_a + signed_b;
                res_reg = add_sub_res[31:0];
                carry_reg = add_sub_res[32]; // For signed addition, carry is not directly used for overflow
                overflow_reg = (signed_a[31] == signed_b[31]) && (signed_a[31] != res_reg[31]);
            end
            ADDU: begin
                add_sub_res = a + b;
                res_reg = add_sub_res[31:0];
                carry_reg = add_sub_res[32];
                overflow_reg = 1'b0; // Unsigned addition does not have overflow in the same sense as signed
            end
            SUB: begin
                add_sub_res = signed_a - signed_b;
                res_reg = add_sub_res[31:0];
                carry_reg = add_sub_res[32]; // For signed subtraction, carry is not directly used for overflow
                overflow_reg = (signed_a[31] != signed_b[31]) && (signed_a[31] != res_reg[31]);
            end
            SUBU: begin
                add_sub_res = a - b;
                res_reg = add_sub_res[31:0];
                carry_reg = add_sub_res[32];
                overflow_reg = 1'b0; // Unsigned subtraction does not have overflow in the same sense as signed
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
                res_reg = (signed_a < signed_b) ? 32'd1 : 32'd0;
            end
            SLTU: begin
                res_reg = (a < b) ? 32'd1 : 32'd0;
            end
            SLL: begin
                res_reg = b << a[4:0];
            end
            SRL: begin
                res_reg = b >> a[4:0];
            end
            SRA: begin
                res_reg = signed_b >>> a[4:0];
            end
            SLLV: begin
                res_reg = b << a;
            end
            SRLV: begin
                res_reg = b >> a;
            end
            SRAV: begin
                res_reg = signed_b >>> a;
            end
            LUI: begin
                res_reg = {b[15:0], 16'h0000};
            end
            default: begin
                res_reg = 32'bz;
            end
        endcase
    end

endmodule