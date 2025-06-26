module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

reg [1:0] state; // 00: idle, 01: saw 0, 10: saw 01

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 2'b00;
        data_out <= 1'b0;
    end else begin
        data_out <= 1'b0; // Default to 0, will be set to 1 only on pulse detection
        case (state)
            2'b00: begin // Idle state or after a pulse
                if (data_in == 1'b0) begin
                    state <= 2'b01; // Saw a 0, waiting for 1
                end else begin
                    state <= 2'b00; // Still 1, stay in idle
                end
            end
            2'b01: begin // Saw a 0, waiting for 1
                if (data_in == 1'b1) begin
                    state <= 2'b10; // Saw a 1, waiting for final 0
                end else begin
                    state <= 2'b01; // Still 0, stay in this state (000... sequence)
                end
            end
            2'b10: begin // Saw 01, waiting for final 0
                if (data_in == 1'b0) begin
                    data_out <= 1'b1; // Pulse detected (010 sequence)
                    state <= 2'b01; // Transition to state 01 (saw a 0 again)
                end else begin
                    state <= 2'b00; // Saw 011, reset to idle
                end
            end
            default: begin // Should not happen, but for completeness
                state <= 2'b00;
                data_out <= 1'b0;
            end
        endcase
    end
end

endmodule