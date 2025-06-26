module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

reg [1:0] state; // 00: IDLE, 01: SAW_0, 10: SAW_01, 11: SAW_010

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 2'b00; // IDLE state
        data_out <= 1'b0;
    end else begin
        data_out <= 1'b0; // Default to 0, set to 1 only when a pulse is detected

        case (state)
            2'b00: begin // IDLE
                if (data_in == 1'b0) begin
                    state <= 2'b01; // Saw first 0
                end else begin
                    state <= 2'b00; // Stay in IDLE if data_in is 1
                end
            end
            2'b01: begin // SAW_0
                if (data_in == 1'b1) begin
                    state <= 2'b10; // Saw 01
                end else begin
                    state <= 2'b01; // Stay in SAW_0 if data_in is 0
                end
            end
            2'b10: begin // SAW_01
                if (data_in == 1'b0) begin
                    state <= 2'b01; // Saw 010, pulse detected, next state is SAW_0
                    data_out <= 1'b1;
                end else begin
                    state <= 2'b00; // Saw 011, not a pulse, go back to IDLE
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