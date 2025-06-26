module alu (
    input  [31:0] a,
    input  [31:0] b,
    input  [5:0]  aluc,
    output [31:0] r,
    output        zero,
    output        carry,
    output        negative,
    output        overflow,
    output        flag
);
    reg [31:0] res;
    wire signed [31:0] signed_a = a;
    wire signed [31:0] signed_b = b;
    wire [31:0] add_result = signed_a + signed_b;
    wire [31:0] sub_result = signed_a - signed_b;
    wire [31:0] and_result = a & b;
    wire [31:0] or_result = a | b;
    wire [31:0] xor_result = a ^ b;
    wire [31:0] nor_result = ~(a | b);
    wire [31:0] slt_result = (signed_a < signed_b) ? 32'b1 : 32'b0;
    wire [31:0] sll_result = b << a[4:0];
    wire [31:0] srl_result = b >> a[4:0];
    wire [31:0] sra_result = signed_b >>> a[4:0];
    wire [31:0] lui_result = {a[15:0], 16'b0};
    
    always @(*) begin
        case (aluc)
            6'b100000: res = add_result;  // ADD
            6'b100001: res = add_result;  // ADDU
            6'b100010: res = sub_result;   // SUB
            6'b100011: res = sub_result;   // SUBU
            6'b100100: res = and_result;   // AND
            6'b100101: res = or_result;    // OR
            6'b100110: res = xor_result;   // XOR
            6'b100111: res = nor_result;   // NOR
            6'b101010: res = slt_result;   // SLT
            6'b101011: res = slt_result;   // SLTU
            6'b000000: res = sll_result;   // SLL
            6'b000010: res = srl_result;   // SRL
            6'b000011: res = sra_result;   // SRA
            6'b000100: res = b << a[4:0];  // SLLV
            6'b000110: res = b >> a[4:0];  // SRLV
            6'b000111: res = signed_b >>> a[4:0]; // SRAV
            6'b001111: res = lui_result;   // LUI
            default: res = 32'bz;          // High impedance
        endcase
    end
    
    assign r = res;
    assign zero = (res == 32'b0);
    assign carry = (aluc == 6'b100000 || aluc == 6'b100001) ? (add_result < signed_a) : 1'b0;
    assign negative = res[31];
    assign overflow = ((signed_a[31] == signed_b[31]) && (res[31] != signed_a[31]));
    assign flag = (aluc == 6'b101010 || aluc == 6'b101011) ? res[0] : 1'bz;
endmodule