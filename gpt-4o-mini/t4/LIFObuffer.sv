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
    reg [1:0] SP;

    always @(posedge Clk) begin
        if (Rst) begin
            SP <= 2'b00;
            stack_mem[0] <= 4'b0000;
            stack_mem[1] <= 4'b0000;
            stack_mem[2] <= 4'b0000;
            stack_mem[3] <= 4'b0000;
        end else if (EN) begin
            if (RW == 1'b0) begin // Write operation
                if (SP < 2'b11) begin
                    stack_mem[SP] <= dataIn;
                    SP <= SP + 1;
                end
            end else begin // Read operation
                if (SP > 2'b00) begin
                    SP <= SP - 1;
                    dataOut <= stack_mem[SP - 1];
                    stack_mem[SP - 1] <= 4'b0000;
                end
            end
        end
        EMPTY <= (SP == 2'b00);
        FULL <= (SP == 2'b11);
    end
endmodule