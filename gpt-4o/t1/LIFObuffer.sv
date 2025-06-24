module LIFObuffer(
    input [3:0] dataIn,
    input RW,
    input EN,
    input Rst,
    input Clk,
    output reg EMPTY,
    output reg FULL,
    output reg [3:0] dataOut
);
    reg [3:0] stack_mem [3:0];
    reg [2:0] SP;

    always @(posedge Clk) begin
        if (Rst) begin
            SP <= 3'b100;
            stack_mem[0] <= 4'b0000;
            stack_mem[1] <= 4'b0000;
            stack_mem[2] <= 4'b0000;
            stack_mem[3] <= 4'b0000;
        end else if (EN) begin
            if (!RW && !FULL) begin
                SP <= SP - 1;
                stack_mem[SP - 1] <= dataIn;
            end else if (RW && !EMPTY) begin
                dataOut <= stack_mem[SP];
                stack_mem[SP] <= 4'b0000;
                SP <= SP + 1;
            end
        end
    end

    always @(*) begin
        EMPTY = (SP == 3'b100);
        FULL = (SP == 3'b000);
    end

endmodule