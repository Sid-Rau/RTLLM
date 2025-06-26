module sequence_detector (
    input clk,
    input reset_n,
    input data_in,
    output reg sequence_detected
);

    reg [2:0] current_state, next_state;

    parameter IDLE = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
            sequence_detected <= 1'b0;
        end
        else begin
            current_state <= next_state;
            if (current_state == S3 && data_in == 1'b1)
                sequence_detected <= 1'b1;
            else
                sequence_detected <= 1'b0;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE: next_state = (data_in == 1'b1) ? S1 : IDLE;
            S1: next_state = (data_in == 1'b0) ? S2 : S1;
            S2: next_state = (data_in == 1'b0) ? S3 : S1;
            S3: next_state = (data_in == 1'b1) ? S4 : IDLE;
            S4: next_state = (data_in == 1'b1) ? S1 : S2;
            default: next_state = IDLE;
        endcase
    end

endmodule