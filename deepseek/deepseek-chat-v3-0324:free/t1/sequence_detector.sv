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
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            IDLE: next_state = data_in ? S1 : IDLE;
            S1: next_state = data_in ? S1 : S2;
            S2: next_state = data_in ? S3 : IDLE;
            S3: next_state = data_in ? S1 : S4;
            S4: next_state = data_in ? S1 : IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sequence_detected <= 1'b0;
        end else begin
            sequence_detected <= (current_state == S3) && (!data_in);
        end
    end

endmodule