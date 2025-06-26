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
reg [2:0] SP; // Stack Pointer, 0 to 3 for valid entries, 4 for empty

always @(posedge Clk) begin
    if (Rst) begin
        SP = 3'd4; // Stack is empty
        EMPTY = 1'b1;
        FULL = 1'b0;
        dataOut = 4'b0;
        stack_mem[0] = 4'b0;
        stack_mem[1] = 4'b0;
        stack_mem[2] = 4'b0;
        stack_mem[3] = 4'b0;
    end else if (EN) begin
        if (!RW) begin // Write operation (Push)
            if (!FULL) begin
                SP = SP - 1;
                stack_mem[SP] = dataIn;
            end
        end else begin // Read operation (Pop)
            if (!EMPTY) begin
                dataOut = stack_mem[SP];
                stack_mem[SP] = 4'b0; // Clear popped data
                SP = SP + 1;
            end
        end

        // Update EMPTY and FULL flags
        if (SP == 3'd4) begin
            EMPTY = 1'b1;
            FULL = 1'b0;
        end else if (SP == 3'd0) begin
            EMPTY = 1'b0;
            FULL = 1'b1;
        end else begin
            EMPTY = 1'b0;
            FULL = 1'b0;
        end
    end
end

endmodule