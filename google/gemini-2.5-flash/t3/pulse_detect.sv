module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

reg [1:0] state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 2'b00; // Initial state
        data_out <= 1'b0;
    end else begin
        data_out <= 1'b0; // Default to 0 unless a pulse is detected
        case (state)
            2'b00: begin // State 0: Waiting for data_in to go high
                if (data_in == 1'b1) begin
                    state <= 2'b01; // Transition to State 1
                end else begin
                    state <= 2'b00; // Stay in State 0
                end
            end
            2'b01: begin // State 1: data_in was high, waiting for it to go low
                if (data_in == 1'b0) begin
                    state <= 2'b10; // Transition to State 2 (pulse detected)
                end else begin
                    state <= 2'b01; // Stay in State 1 (data_in still high)
                end
            end
            2'b10: begin // State 2: Pulse detected, output high for this cycle
                data_out <= 1'b1;
                if (data_in == 1'b1) begin
                    state <= 2'b01; // If data_in goes high again, start new potential pulse
                end else begin
                    state <= 2'b00; // If data_in stays low, reset to initial state
                end
            end
            default: begin
                state <= 2'b00; // Should not happen, but good for robustness
                data_out <= 1'b0;
            end
        endcase
    end
end

endmodule