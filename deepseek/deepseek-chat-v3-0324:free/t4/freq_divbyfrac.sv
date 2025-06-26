module freq_divbyfrac (
    input clk,
    input rst_n,
    output clk_div
);

    reg [2:0] counter;
    reg clk_div_a, clk_div_b;
    reg clk_div_a_delayed, clk_div_b_advanced;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'd0;
            clk_div_a <= 1'b0;
        end
        else begin
            if (counter == 3'd6) begin
                counter <= 3'd0;
                clk_div_a <= ~clk_div_a;
            end
            else begin
                counter <= counter + 3'd1;
                if (counter == 3'd3)
                    clk_div_a <= ~clk_div_a;
            end
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_a_delayed <= 1'b0;
        end
        else begin
            clk_div_a_delayed <= clk_div_a;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_b <= 1'b0;
        end
        else begin
            if (counter == 3'd6) begin
                clk_div_b <= ~clk_div_b;
            end
            else if (counter == 3'd2) begin
                clk_div_b <= ~clk_div_b;
            end
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_b_advanced <= 1'b0;
        end
        else begin
            clk_div_b_advanced <= clk_div_b;
        end
    end

    assign clk_div = clk_div_a_delayed | clk_div_b_advanced;

endmodule