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

    always @(state or cnt or pass_request) begin
        case (state)
            idle: begin
                next_state = s1_red;
            end
            s1_red: begin
                red = 1;
                yellow = 0;
                green = 0;
                if (cnt == 0) next_state = s3_green;
                else next_state = s1_red;
            end
            s2_yellow: begin
                red = 0;
                yellow = 1;
                green = 0;
                if (cnt == 0) next_state = s1_red;
                else next_state = s2_yellow;
            end
            s3_green: begin
                red = 0;
                yellow = 0;
                green = 1;
                if (cnt == 0) next_state = s2_yellow;
                else next_state = s3_green;
            end
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
            end else if (cnt > 0) begin
                cnt <= cnt - 1;
            end
        end
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