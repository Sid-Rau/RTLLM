module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

reg [1:0] state; // 00: IDLE, 01: SAW_ONE, 10: SAW_ONE_ZERO

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 2'b00;
        data_out <= 1'b0;
    end else begin
        data_out <= 1'b0; // Default to 0, set to 1 only when pulse detected

        case (state)
            2'b00: begin // IDLE state
                if (data_in == 1'b1) begin
                    state <= 2'b01; // Transition to SAW_ONE
                end else begin
                    state <= 2'b00; // Stay in IDLE
                end
            end
            2'b01: begin // SAW_ONE state (data_in was 1 in previous cycle)
                if (data_in == 1'b0) begin
                    state <= 2'b10; // Transition to SAW_ONE_ZERO
                end else begin
                    state <= 2'b01; // Stay in SAW_ONE (still seeing 1)
                end
            end
            2'b10: begin // SAW_ONE_ZERO state (data_in was 0 in previous cycle, 1 before that)
                data_out <= 1'b1; // Pulse detected!

                if (data_in == 1'b1) begin
                    state <= 2'b01; // Start new potential pulse sequence
                end else begin
                    state <= 2'b00; // Back to IDLE, no new pulse started
                end
            end
            default: begin
                state <= 2'b00; // Should not happen, but for safety
                data_out <= 1'b0;
            end
        endcase
    end
end

endmodule