module freq_divbyfrac (
    input wire clk,
    input wire rst_n,
    output reg clk_div
);

    reg [2:0] counter;
    reg clk_div_even, clk_div_odd;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'b0;
            clk_div_even <= 1'b0;
        end else begin
            if (counter == 3'b110) begin
                counter <= 3'b0;
                clk_div_even <= ~clk_div_even;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end

    always @(negedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div_odd <= 1'b0;
        end else begin
            if (counter == 3'b011) begin
                clk_div_odd <= ~clk_div_odd;
            end
        end
    end

    always @(*) begin
        clk_div = clk_div_even | clk_div_odd;
    end

endmodule