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

wire signed [31:0] signed_a = a;
wire signed [31:0] signed_b = b;
reg [32:0] res;
wire [31:0] shift_amount = (aluc[2:0] == 3'b100 || aluc[2:0] == 3'b110 || aluc[2:0] == 3'b111) ? a[4:0] : b[4:0];

assign zero = (r == 32'b0);
assign carry = res[32];
assign negative = r[31];
assign overflow = (aluc == ADD || aluc == SUB) ? (res[32] ^ res[31]) : 1'b0;
assign flag = (aluc == SLT) ? (signed_a < signed_b) : (aluc == SLTU) ? (a < b) : 1'bz;

always @(*) begin
    case (aluc)
        ADD: res = signed_a + signed_b;
        ADDU: res = a + b;
        SUB: res = signed_a - signed_b;
        SUBU: res = a - b;
        AND: res = a & b;
        OR: res = a | b;
        XOR: res = a ^ b;
        NOR: res = ~(a | b);
        SLT: res = (signed_a < signed_b) ? 1 : 0;
        SLTU: res = (a < b) ? 1 : 0;
        SLL: res = b << shift_amount;
        SRL: res = b >> shift_amount;
        SRA: res = $signed(b) >>> shift_amount;
        SLLV: res = b << shift_amount;
        SRLV: res = b >> shift_amount;
        SRAV: res = $signed(b) >>> shift_amount;
        LUI: res = {b[15:0], 16'b0};
        default: res = 33'bz;
    endcase
    r = res[31:0];
end

endmodule