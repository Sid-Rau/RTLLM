module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

    reg [1:0] state;
    reg [1:0] next_state;

    localparam IDLE = 2'b00,
               DETECT_1 = 2'b01,
               DETECT_0 = 2'b10,
               PULSE = 2'b11;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE: begin
                if (data_in)
                    next_state = DETECT_1;
                else
                    next_state = IDLE;
                data_out = 0;
            end
            DETECT_1: begin
                if (!data_in)
                    next_state = DETECT_0;
                else
                    next_state = DETECT_1;
                data_out = 0;
            end
            DETECT_0: begin
                if (data_in)
                    next_state = DETECT_1;
                else
                    next_state = PULSE;
                data_out = 0;
            end
            PULSE: begin
                next_state = IDLE;
                data_out = 1;
            end
            default: begin
                next_state = IDLE;
                data_out = 0;
            end
        endcase
    end

endmodule