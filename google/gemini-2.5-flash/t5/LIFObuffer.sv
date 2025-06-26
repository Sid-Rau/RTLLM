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

reg [3:0] stack_mem [3:0];
reg [2:0] SP; // Stack Pointer, 0 to 4 (4 indicating empty)

always @(posedge Clk) begin
    if (Rst) begin
        SP = 3'd4; // Stack pointer initialized to 4 (empty)
        EMPTY = 1'b1;
        FULL = 1'b0;
        dataOut = 4'b0;
        stack_mem[0] = 4'b0;
        stack_mem[1] = 4'b0;
        stack_mem[2] = 4'b0;
        stack_mem[3] = 4'b0;
    end else if (EN) begin
        if (!RW) begin // Write operation
            if (!FULL) begin
                SP = SP - 3'd1;
                stack_mem[SP] = dataIn;
            end
        end else begin // Read operation
            if (!EMPTY) begin
                dataOut = stack_mem[SP];
                stack_mem[SP] = 4'b0; // Clear memory location after pop
                SP = SP + 3'd1;
            end
        end

        // Update EMPTY and FULL flags
        if (SP == 3'd4) begin
            EMPTY = 1'b1;
        end else begin
            EMPTY = 1'b0;
        end

        if (SP == 3'd0) begin
            FULL = 1'b1;
        end else begin
            FULL = 1'b0;
        end

        // If read operation was performed on an empty buffer, dataOut should be 0
        if (RW && EMPTY) begin
            dataOut = 4'b0;
        end
    end
end

endmodule