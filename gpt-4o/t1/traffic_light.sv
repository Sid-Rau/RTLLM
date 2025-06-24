module traffic_light(
    input wire rst_n,
    input wire clk,
    input wire pass_request,
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
        end else begin
            case (state)
                idle: state <= s1_red;
                s1_red: if (cnt == 0) state <= s3_green;
                s2_yellow: if (cnt == 0) state <= s1_red;
                s3_green: if (cnt == 0) state <= s2_yellow;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd10;
        end else begin
            if (state == s3_green && pass_request && cnt > 10) begin
                cnt <= 8'd10;
            end else if (state == s3_green && !p_green) begin
                cnt <= 8'd60;
            end else if (state == s2_yellow && !p_yellow) begin
                cnt <= 8'd5;
            end else if (state == s1_red && !p_red) begin
                cnt <= 8'd10;
            end else if (cnt != 0) begin
                cnt <= cnt - 1;
            end
        end
    end

    assign clock = cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            red <= 1'b0;
            yellow <= 1'b0;
            green <= 1'b0;
        end else begin
            p_red <= red;
            p_yellow <= yellow;
            p_green <= green;
            case (state)
                idle: begin
                    red <= 1'b0;
                    yellow <= 1'b0;
                    green <= 1'b0;
                end
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
            endcase
        end
    end

endmodule