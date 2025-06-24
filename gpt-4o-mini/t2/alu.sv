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
    assign r = res;
    assign zero = (res == 32'b0);
    assign negative = res[31];
    assign flag = (aluc == 6'b101010) ? (a < b) : (aluc == 6'b101011) ? ($unsigned(a) < $unsigned(b)) : 1'bz;

    always @(*) begin
        case (aluc)
            6'b100000: {carry, res} = a + b; // ADD
            6'b100001: {carry, res} = a + b; // ADDU
            6'b100010: {carry, res} = a - b; // SUB
            6'b100011: {carry, res} = a - b; // SUBU
            6'b100100: res = a & b;           // AND
            6'b100101: res = a | b;           // OR
            6'b100110: res = a ^ b;           // XOR
            6'b100111: res = ~(a | b);        // NOR
            6'b101010: res = (a < b) ? 32'b1 : 32'b0; // SLT
            6'b101011: res = ($unsigned(a) < $unsigned(b)) ? 32'b1 : 32'b0; // SLTU
            6'b000000: res = b << a[4:0];     // SLL
            6'b000010: res = b >> a[4:0];     // SRL
            6'b000011: res = $signed(b) >>> a[4:0]; // SRA
            6'b000100: res = b << a;           // SLLV
            6'b000110: res = b >> a;           // SRLV
            6'b000111: res = $signed(b) >>> a; // SRAV
            6'b001111: res = {a[15:0], 16'b0}; // LUI
            default: res = 32'bz;              // Default case
        endcase
    end

    assign overflow = (aluc == 6'b100000 || aluc == 6'b100010) && ((a[31] == b[31]) && (res[31] != a[31]));
endmodule