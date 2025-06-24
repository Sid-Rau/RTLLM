module traffic_light(
    input rst_n,
    input clk,
    input pass_request,
    output reg [7:0] clock,
    output reg red,
    output reg yellow,
    output reg green
);

    typedef enum reg [1:0] {
        idle = 2'b00,
        s1_red = 2'b01,
        s2_yellow = 2'b10,
        s3_green = 2'b11
    } state_t;

    reg [7:0] cnt;
    reg [1:0] state;
    reg p_red, p_yellow, p_green;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
            p_red <= 0;
            p_yellow <= 0;
            p_green <= 0;
        end else begin
            case (state)
                idle: begin
                    state <= s1_red;
                end
                s1_red: begin
                    p_red <= 1;
                    p_yellow <= 0;
                    p_green <= 0;
                    if (cnt == 0) state <= s3_green;
                end
                s2_yellow: begin
                    p_red <= 0;
                    p_yellow <= 1;
                    p_green <= 0;
                    if (cnt == 0) state <= s1_red;
                end
                s3_green: begin
                    p_red <= 0;
                    p_yellow <= 0;
                    p_green <= 1;
                    if (cnt == 0) state <= s2_yellow;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 10;
        end else begin
            if (pass_request && p_green && cnt > 10) begin
                cnt <= 10;
            end else if (!p_green && p_yellow) begin
                cnt <= 5;
            end else if (!p_yellow && p_red) begin
                cnt <= 10;
            end else if (!p_red && p_green) begin
                cnt <= 60;
            end else if (cnt > 0) begin
                cnt <= cnt - 1;
            end
        end
    end

    assign clock = cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            red <= 0;
            yellow <= 0;
            green <= 0;
        end else begin
            red <= p_red;
            yellow <= p_yellow;
            green <= p_green;
        end
    end

endmodule