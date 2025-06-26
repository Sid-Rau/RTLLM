module LIFObuffer (
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
            stack_mem[0] <= 4'b0;
            stack_mem[1] <= 4'b0;
            stack_mem[2] <= 4'b0;
            stack_mem[3] <= 4'b0;
            EMPTY <= 1'b1;
            FULL <= 1'b0;
        end
        else if (EN) begin
            if (!RW && !FULL) begin
                stack_mem[SP-1] <= dataIn;
                SP <= SP - 1;
            end
            else if (RW && !EMPTY) begin
                dataOut <= stack_mem[SP];
                stack_mem[SP] <= 4'b0;
                SP <= SP + 1;
            end

            EMPTY <= (SP == 3'b100);
            FULL <= (SP == 3'b000);
        end
    end

endmodule