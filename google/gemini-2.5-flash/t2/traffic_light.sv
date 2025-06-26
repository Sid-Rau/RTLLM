module traffic_light (
    input rst_n,
    input clk,
    input pass_request,
    output [7:0] clock,
    output reg red,
    output reg yellow,
    output reg green
);

parameter idle = 2'b00, s1_red = 2'b01, s2_yellow = 2'b10, s3_green = 2'b11;

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
                if (cnt == 0) begin
                    state <= s3_green;
                end else begin
                    state <= s1_red;
                end
            end
            s2_yellow: begin
                p_red <= 1'b0;
                p_yellow <= 1'b1;
                p_green <= 1'b0;
                if (cnt == 0) begin
                    state <= s1_red;
                end else begin
                    state <= s2_yellow;
                end
            end
            s3_green: begin
                p_red <= 1'b0;
                p_yellow <= 1'b0;
                p_green <= 1'b1;
                if (cnt == 0) begin
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
        cnt <= 10;
    end else begin
        if (pass_request && p_green && cnt > 10) begin
            cnt <= 10;
        end else if (p_green == 1'b0 && green == 1'b1) begin // Transition from green to non-green
            cnt <= 60;
        end else if (p_yellow == 1'b0 && yellow == 1'b1) begin // Transition from yellow to non-yellow
            cnt <= 5;
        end else if (p_red == 1'b0 && red == 1'b1) begin // Transition from red to non-red
            cnt <= 10;
        end else if (cnt > 0) begin
            cnt <= cnt - 1;
        end else begin
            cnt <= 0; // Prevent negative count
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
        red <= p_red;
        yellow <= p_yellow;
        green <= p_green;
    end
end

endmodule