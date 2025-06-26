module freq_divbyfrac(
    input clk,
    input rst_n,
    output reg clk_div
);
    reg [2:0] count;
    reg clk_int1, clk_int2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            clk_int1 <= 0;
            clk_int2 <= 0;
        end else begin
            if (count < 7) begin
                count <= count + 1;
            end else begin
                count <= 0;
            end

            if (count < 4) begin
                clk_int1 <= 1;
            end else begin
                clk_int1 <= 0;
            end
            
            if (count < 3) begin
                clk_int2 <= 1;
            end else begin
                clk_int2 <= 0;
            end

            clk_div <= clk_int1 | clk_int2;
        end
    end
endmodule