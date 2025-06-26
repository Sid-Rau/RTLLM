module traffic_light(
    input wire rst_n,
    input wire clk,
    input wire pass_request,
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
            cnt <= 10;
        end else begin
            state <= next_state;
            if (state == s3_green && cnt > 10) 
                cnt <= 10;
            else if (state == s3_green && p_green)
                cnt <= 60;
            else if (state == s2_yellow && p_yellow)
                cnt <= 5;
            else if (state == s1_red && p_red)
                cnt <= 10;
            else if (cnt > 0)
                cnt <= cnt - 1;
        end
    end

    always @(*) begin
        case(state)
            idle: begin
                next_state = s1_red;
                red = 0; yellow = 0; green = 0;
            end
            s1_red: begin
                if (cnt == 0) begin
                    next_state = s3_green;
                    red = 1; yellow = 0; green = 0;
                end else begin
                    next_state = s1_red;
                    red = 1; yellow = 0; green = 0;
                end
            end
            s2_yellow: begin
                if (cnt == 0) begin
                    next_state = s1_red;
                    red = 0; yellow = 0; green = 0;
                end else begin
                    next_state = s2_yellow;
                    red = 0; yellow = 1; green = 0;
                end
            end
            s3_green: begin
                if (cnt == 0) begin
                    next_state = s2_yellow;
                    red = 0; yellow = 0; green = 1;
                end else begin
                    next_state = s3_green;
                    red = 0; yellow = 0; green = 1;
                end
            end
            default: begin
                next_state = idle;
                red = 0; yellow = 0; green = 0;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_red <= 0;
            p_yellow <= 0;
            p_green <= 0;
        end else begin
            p_red <= red;
            p_yellow <= yellow;
            p_green <= green;
        end
    end

    assign clock = cnt;

endmodule