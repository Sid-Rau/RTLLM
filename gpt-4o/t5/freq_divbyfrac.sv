module freq_divbyfrac (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);

    reg [2:0] counter;
    reg clk_div_half1, clk_div_half2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'd0;
            clk_div_half1 <= 1'b0;
        end else begin
            if (counter < 3'd3) begin
                clk_div_half1 <= 1'b1;
            end else begin
                clk_div_half1 <= 1'b0;
            end

            if (counter == 3'd6) begin
                counter <= 3'd0;
            end else begin
                counter <= counter + 3'd1;
            end
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_half2 <= 1'b0;
        end else begin
            if (counter < 3'd3) begin
                clk_div_half2 <= 1'b0;
            end else begin
                clk_div_half2 <= 1'b1;
            end
        end
    end

    always @(*) begin
        clk_div = clk_div_half1 | clk_div_half2;
    end

endmodule