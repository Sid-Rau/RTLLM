module traffic_light(
    input rst_n,
    input clk,
    input pass_request,
    output [7:0] clock,
    output red,
    output yellow,
    output green
);

    parameter idle = 2'b00;
    parameter s1_red = 2'b01;
    parameter s2_yellow = 2'b10;
    parameter s3_green = 2'b11;

    reg [7:0] cnt;
    reg [1:0] state;
    reg p_red, p_yellow, p_green;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= idle;
        end else begin
            case (state)
                idle: state <= s1_red;
                s1_red: state <= (cnt == 8'd0) ? s3_green : s1_red;
                s2_yellow: state <= (cnt == 8'd0) ? s1_red : s2_yellow;
                s3_green: state <= (cnt == 8'd0) ? s2_yellow : s3_green;
                default: state <= idle;
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 8'd10;
        end else if (pass_request && green && cnt > 8'd10) begin
            cnt <= 8'd10;
        end else if (!green && p_green) begin
            cnt <= 8'd60;
        end else if (!yellow && p_yellow) begin
            cnt <= 8'd5;
        end else if (!red && p_red) begin
            cnt <= 8'd10;
        end else begin
            cnt <= cnt - 8'd1;
        end
    end

    assign clock = cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            p_red <= 1'b0;
            p_yellow <= 1'b0;
            p_green <= 1'b0;
        end else begin
            p_red <= (state == s1_red);
            p_yellow <= (state == s2_yellow);
            p_green <= (state == s3_green);
        end
    end

    assign red = p_red;
    assign yellow = p_yellow;
    assign green = p_green;

endmodule