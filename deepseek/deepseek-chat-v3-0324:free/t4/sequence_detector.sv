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
        sequence_detected = 1'b0;
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (data_in == 1'b1) begin
                    next_state = S1;
                end
            end
            S1: begin
                if (data_in == 1'b0) begin
                    next_state = S2;
                end
            end
            S2: begin
                if (data_in == 1'b0) begin
                    next_state = S3;
                end else begin
                    next_state = S1;
                end
            end
            S3: begin
                if (data_in == 1'b1) begin
                    next_state = S4;
                end else begin
                    next_state = IDLE;
                end
            end
            S4: begin
                sequence_detected = 1'b1;
                if (data_in == 1'b1) begin
                    next_state = S1;
                end else begin
                    next_state = S2;
                end
            end
            default: next_state = IDLE;
        endcase
    end

endmodule