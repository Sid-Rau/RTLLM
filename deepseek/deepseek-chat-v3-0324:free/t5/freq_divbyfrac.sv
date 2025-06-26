module freq_divbyfrac (
    input clk,
    input rst_n,
    output clk_div
);

    reg [2:0] counter;
    reg clk_div_a;
    reg clk_div_b;
    reg clk_div_a_d;
    reg clk_div_b_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'b0;
            clk_div_a <= 1'b0;
            clk_div_b <= 1'b0;
        end else begin
            if (counter == 3'd6) begin
                counter <= 3'b0;
            end else begin
                counter <= counter + 1'b1;
            end

            if (counter < 3'd3) begin
                clk_div_a <= 1'b1;
            end else begin
                clk_div_a <= 1'b0;
            end

            if (counter < 3'd4) begin
                clk_div_b <= 1'b1;
            end else begin
                clk_div_b <= 1'b0;
            end
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_a_d <= 1'b0;
            clk_div_b_d <= 1'b0;
        end else begin
            clk_div_a_d <= clk_div_a;
            clk_div_b_d <= clk_div_b;
        end
    end

    assign clk_div = (clk_div_a & clk_div_b_d) | (clk_div_b & clk_div_a_d);

endmodule