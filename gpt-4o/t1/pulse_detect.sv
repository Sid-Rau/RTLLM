module pulse_detect (
    input wire clk,
    input wire rst_n,
    input wire data_in,
    output reg data_out
);

    typedef enum reg [1:0] {
        IDLE = 2'b00,
        PULSE_START = 2'b01,
        PULSE_MID = 2'b10
    } state_t;

    state_t state, next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        next_state = state;
        data_out = 1'b0;
        case (state)
            IDLE: begin
                if (data_in)
                    next_state = PULSE_START;
            end
            PULSE_START: begin
                if (!data_in)
                    next_state = PULSE_MID;
            end
            PULSE_MID: begin
                if (data_in)
                    next_state = PULSE_START;
                else begin
                    next_state = IDLE;
                    data_out = 1'b1;
                end
            end
        endcase
    end

endmodule