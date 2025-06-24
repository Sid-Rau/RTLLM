module freq_divbyfrac (
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
            if (count < 3'd4) begin
                clk_int <= 1'b1; // First 4 cycles
            end else begin
                clk_int <= 1'b0; // Next 3 cycles
            end
            
            count <= (count == 3'd6) ? 3'b000 : count + 3'b001;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 1'b0;
        end else begin
            clk_div <= clk_int | clk_div; // ORing for the final output
        end
    end
endmodule