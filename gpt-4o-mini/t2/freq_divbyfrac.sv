module freq_divbyfrac(
    input clk,
    input rst_n,
    output reg clk_div
);
    reg [2:0] count;
    reg clk_int;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 3'b000;
            clk_int <= 1'b0;
        end else begin
            if (count < 3'd6) begin
                count <= count + 1'b1;
            end else begin
                count <= 3'b000;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_int <= 1'b0;
        end else begin
            if (count < 3'd4) begin
                clk_int <= 1'b1;
            end else begin
                clk_int <= 1'b0;
            end
        end
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 1'b0;
        end else begin
            clk_div <= clk_int | clk_int;
        end
    end
endmodule