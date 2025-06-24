module traffic_light(
    input rst_n,
    input clk,
    input pass_request,
    output reg [7:0] clock,
    output reg red,
    output reg yellow,
    output reg green
);
    reg [7:0] cnt;
    reg [1:0] state, next_state;
    reg p_red, p_yellow, p_green;

    parameter idle = 2'b00, s1_red = 2'b01, s2_yellow = 2'b10, s3_green = 2'b11;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            idle: next_state = s1_red;
            s1_red: if (cnt == 0) next_state = s3_green; else next_state = s1_red;
            s2_yellow: if (cnt == 0) next_state = s1_red; else next_state = s2_yellow;
            s3_green: if (cnt == 0) next_state = s2_yellow; else next_state = s3_green;
            default: next_state = idle;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 10;
        end else begin
            case (state)
                s1_red: begin
                    if (cnt == 0) cnt <= 10; // Reset for next state
                    else cnt <= cnt - 1;
                end
                s2_yellow: begin
                    if (cnt == 0) cnt <= 5; // Reset for next state
                    else cnt <= cnt - 1;
                end
                s3_green: begin
                    if (cnt == 0) cnt <= 60; // Reset for next state
                    else if (pass_request && cnt > 10) cnt <= 10;
                    else cnt <= cnt - 1;
                end
                default: cnt <= cnt; // Hold current count
            endcase
        end
    end

    always @(*) begin
        case (state)
            s1_red: begin
                red = 1; yellow = 0; green = 0;
            end
            s2_yellow: begin
                red = 0; yellow = 1; green = 0;
            end
            s3_green: begin
                red = 0; yellow = 0; green = 1;
            end
            default: begin
                red = 0; yellow = 0; green = 0;
            end
        endcase
    end

    assign clock = cnt;

endmodule