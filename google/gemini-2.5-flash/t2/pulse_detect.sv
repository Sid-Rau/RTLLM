module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

reg [1:0] state; // 00: IDLE, 01: SAW_0, 10: SAW_01

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 2'b00;
        data_out <= 1'b0;
    end else begin
        data_out <= 1'b0; // Default to 0, set to 1 only on pulse detection

        case (state)
            2'b00: begin // IDLE state (expecting 0)
                if (data_in == 1'b0) begin
                    state <= 2'b01; // Saw a 0, move to SAW_0 state
                end else begin
                    state <= 2'b00; // Still waiting for a 0
                end
            end
            2'b01: begin // SAW_0 state (expecting 1)
                if (data_in == 1'b1) begin
                    state <= 2'b10; // Saw a 1, move to SAW_01 state
                end else begin
                    state <= 2'b01; // Still waiting for a 1, stay in SAW_0 state
                end
            end
            2'b10: begin // SAW_01 state (expecting 0 for pulse completion)
                if (data_in == 1'b0) begin
                    data_out <= 1'b1; // Pulse detected (0->1->0)
                    state <= 2'b01; // Reset to SAW_0 state, ready for next 0
                end else begin
                    state <= 2'b00; // Sequence broken (0->1->1), go back to IDLE
                end
            end
            default: begin
                state <= 2'b00; // Should not happen, reset to IDLE
                data_out <= 1'b0;
            end
        endcase
    end
end

endmodule