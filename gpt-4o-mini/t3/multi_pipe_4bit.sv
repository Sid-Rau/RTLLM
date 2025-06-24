module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);
    parameter size = 4;
    reg [7:0] partial_product [0:size-1];
    reg [7:0] sum_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 8'd0;
            sum_reg <= 8'd0;
        end else begin
            sum_reg <= 8'd0;
            for (integer i = 0; i < size; i = i + 1) begin
                partial_product[i] = (mul_b[i] == 1'b1) ? (mul_a << i) : 8'd0;
                sum_reg = sum_reg + partial_product[i];
            end
            mul_out <= sum_reg;
        end
    end
endmodule