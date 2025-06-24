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

    reg [3:0] stack_mem [0:3];
    reg [2:0] SP;

    always @(posedge Clk) begin
        if (Rst) begin
            SP <= 3'b100;
            stack_mem[0] <= 4'b0000;
            stack_mem[1] <= 4'b0000;
            stack_mem[2] <= 4'b0000;
            stack_mem[3] <= 4'b0000;
            EMPTY <= 1;
            FULL <= 0;
        end else if (EN) begin
            if (RW == 0 && !FULL) begin
                SP <= SP - 1;
                stack_mem[SP - 1] <= dataIn;
                FULL <= (SP == 3'b001);
                EMPTY <= 0;
            end else if (RW == 1 && !EMPTY) begin
                dataOut <= stack_mem[SP];
                stack_mem[SP] <= 4'b0000;
                SP <= SP + 1;
                EMPTY <= (SP == 3'b100);
                FULL <= 0;
            end
        end
    end

endmodule