module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output [7:0] clock,
    output red,
    output yellow,
    output green
);

parameter idle = 2'b00,
          s1_red = 2'b01,
          s2_yellow = 2'b10,
          s3_green = 2'b11;

reg [7:0] cnt;
reg [1:0] state;
reg p_red, p_yellow, p_green;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= idle;
        p_red <= 1'b0;
        p_yellow <= 1'b0;
        p_green <= 1'b0;
    end else begin
        case (state)
            idle: begin
                p_red <= 1'b0;
                p_yellow <= 1'b0;
                p_green <= 1'b0;
                state <= s1_red;
            end
            s1_red: begin
                p_red <= 1'b1;
                p_yellow <= 1'b0;
                p_green <= 1'b0;
                if (cnt == 8'd1) begin
                    state <= s3_green;
                end else begin
                    state <= s1_red;
                end
            end
            s2_yellow: begin
                p_red <= 1'b0;
                p_yellow <= 1'b1;
                p_green <= 1'b0;
                if (cnt == 8'd1) begin
                    state <= s1_red;
                end else begin
                    state <= s2_yellow;
                end
            end
            s3_green: begin
                p_red <= 1'b0;
                p_yellow <= 1'b0;
                p_green <= 1'b1;
                if (cnt == 8'd1) begin
                    state <= s2_yellow;
                end else begin
                    state <= s3_green;
                end
            end
            default: begin
                state <= idle;
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 8'd10;
    end else begin
        if (pass_request && p_green && cnt > 8'd10) begin
            cnt <= 8'd10;
        end else if (!p_green && green) begin // Transition from green to next state
            cnt <= 8'd60;
        end else if (!p_yellow && yellow) begin // Transition from yellow to next state
            cnt <= 8'd5;
        end else if (!p_red && red) begin // Transition from red to next state
            cnt <= 8'd10;
        end else begin
            cnt <= cnt - 8'd1;
        end
    end
end

assign clock = cnt;
assign red = p_red;
assign yellow = p_yellow;
assign green = p_green;

endmodule