module freq_divbyfrac (
    input clk,
    input rst_n,
    output clk_div
);

    reg [2:0] cnt;
    reg clk_div_a, clk_div_b;
    reg clk_div_a_dly, clk_div_b_dly;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 3'b0;
        end else begin
            if (cnt == 3'd6) begin
                cnt <= 3'b0;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_a <= 1'b0;
        end else begin
            if (cnt == 3'd0) begin
                clk_div_a <= 1'b1;
            end else if (cnt == 3'd4) begin
                clk_div_a <= 1'b0;
            end
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_a_dly <= 1'b0;
        end else begin
            clk_div_a_dly <= clk_div_a;
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_b <= 1'b0;
        end else begin
            if (cnt == 3'd3) begin
                clk_div_b <= 1'b1;
            end else if (cnt == 3'd0) begin
                clk_div_b <= 1'b0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_b_dly <= 1'b0;
        end else begin
            clk_div_b_dly <= clk_div_b;
        end
    end

    assign clk_div = clk_div_a_dly | clk_div_b_dly;

endmodule