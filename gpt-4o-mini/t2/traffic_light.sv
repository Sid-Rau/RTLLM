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
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case(state)
            idle: next_state = s1_red;
            s1_red: next_state = (cnt == 8'd10) ? s3_green : s1_red;
            s2_yellow: next_state = (cnt == 8'd5) ? s1_red : s2_yellow;
            s3_green: next_state = (cnt == 8'd60) ? s2_yellow : s3_green;
            default: next_state = idle;
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd10;
        end else begin
            if (pass_request && green) begin
                cnt <= 8'd10;
            end else if (!green && p_green) begin
                cnt <= 8'd60;
            end else if (!yellow && p_yellow) begin
                cnt <= 8'd5;
            end else if (!red && p_red) begin
                cnt <= 8'd10;
            end else begin
                if (cnt > 0) cnt <= cnt - 1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_red <= 1'b0;
            p_yellow <= 1'b0;
            p_green <= 1'b0;
        end else begin
            p_red <= red;
            p_yellow <= yellow;
            p_green <= green;
            case(state)
                s1_red: begin
                    red <= 1'b1;
                    yellow <= 1'b0;
                    green <= 1'b0;
                end
                s2_yellow: begin
                    red <= 1'b0;
                    yellow <= 1'b1;
                    green <= 1'b0;
                end
                s3_green: begin
                    red <= 1'b0;
                    yellow <= 1'b0;
                    green <= 1'b1;
                end
                default: begin
                    red <= 1'b0;
                    yellow <= 1'b0;
                    green <= 1'b0;
                end
            endcase
        end
    end

    assign clock = cnt;

endmodule