module traffic_light(
    input wire rst_n,
    input wire clk,
    input wire pass_request,
    output reg [7:0] clock,
    output reg red,
    output reg yellow,
    output reg green
);

    parameter idle = 2'b00, s1_red = 2'b01, s2_yellow = 2'b10, s3_green = 2'b11;
    reg [1:0] state;
    reg [7:0] cnt;
    reg p_red, p_yellow, p_green;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
            cnt <= 8'd10;
        end else begin
            case (state)
                idle: begin
                    red <= 0;
                    yellow <= 0;
                    green <= 0;
                    state <= s1_red;
                end
                s1_red: begin
                    red <= 1;
                    yellow <= 0;
                    green <= 0;
                    if (cnt == 8'd0) begin
                        state <= s3_green;
                    end
                end
                s2_yellow: begin
                    red <= 0;
                    yellow <= 1;
                    green <= 0;
                    if (cnt == 8'd0) begin
                        state <= s1_red;
                    end
                end
                s3_green: begin
                    red <= 0;
                    yellow <= 0;
                    green <= 1;
                    if (cnt == 8'd0) begin
                        state <= s2_yellow;
                    end
                end
                default: state <= idle;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd10;
        end else begin
            if (cnt > 0) begin
                cnt <= cnt - 1;
            end else begin
                if (state == s3_green) begin
                    if (pass_request && cnt > 10) begin
                        cnt <= 8'd10;
                    end else begin
                        cnt <= 8'd60;
                    end
                end else if (state == s2_yellow) begin
                    cnt <= 8'd5;
                end else if (state == s1_red) begin
                    cnt <= 8'd10;
                end
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