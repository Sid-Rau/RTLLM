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
    reg [2:0] SP; // 3-bit stack pointer to track positions 0 to 4

    always @(posedge Clk) begin
        if (Rst) begin
            stack_mem[0] <= 4'b0000;
            stack_mem[1] <= 4'b0000;
            stack_mem[2] <= 4'b0000;
            stack_mem[3] <= 4'b0000;
            SP <= 3'b100; // Stack is empty
            EMPTY <= 1;
            FULL <= 0;
        end else if (EN) begin
            if (RW == 0) begin // Write operation
                if (!FULL) begin
                    SP <= SP - 1;
                    stack_mem[SP - 1] <= dataIn;
                    EMPTY <= 0;
                    if (SP == 3'b001)
                        FULL <= 1;
                end
            end else begin // Read operation
                if (!EMPTY) begin
                    dataOut <= stack_mem[SP];
                    stack_mem[SP] <= 4'b0000;
                    SP <= SP + 1;
                    FULL <= 0;
                    if (SP == 3'b100)
                        EMPTY <= 1;
                end
            end
        end
    end

endmodule