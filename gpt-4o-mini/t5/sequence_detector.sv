module sequence_detector (
    input clk,
    input reset_n,
    input data_in,
    output reg sequence_detected
);
    typedef enum reg [2:0] {
        IDLE = 3'b000,
        S1   = 3'b001,
        S2   = 3'b010,
        S3   = 3'b011,
        S4   = 3'b100
    } state_t;

    state_t current_state, next_state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            IDLE: begin
                if (data_in)
                    next_state = S1;
                else
                    next_state = IDLE;
            end
            S1: begin
                if (!data_in)
                    next_state = S2;
                else
                    next_state = S1;
            end
            S2: begin
                if (data_in)
                    next_state = S3;
                else
                    next_state = IDLE;
            end
            S3: begin
                if (!data_in)
                    next_state = S4;
                else
                    next_state = S1;
            end
            S4: begin
                next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            sequence_detected <= 1'b0;
        else if (current_state == S4)
            sequence_detected <= 1'b1;
        else
            sequence_detected <= 1'b0;
    end
endmodule