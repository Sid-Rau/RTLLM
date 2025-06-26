module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);
    reg mul_en_out_reg;
    reg [7:0] mul_a_reg, mul_b_reg;
    reg [15:0] partial_products[7:0];
    reg [15:0] sum[7:0];
    reg [15:0] mul_out_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 0;
            mul_a_reg <= 0;
            mul_b_reg <= 0;
            mul_out_reg <= 0;
            mul_out <= 0;
        end else begin
            mul_en_out_reg <= mul_en_in;
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end
            mul_en_out <= mul_en_out_reg;

            for (integer i = 0; i < 8; i = i + 1) begin
                partial_products[i] <= (mul_a_reg & {8{mul_b_reg[i]}}) << i;
            end

            sum[0] <= partial_products[0];
            for (integer j = 1; j < 8; j = j + 1) begin
                sum[j] <= sum[j-1] + partial_products[j];
            end
            
            mul_out_reg <= sum[7];
            mul_out <= mul_en_out_reg ? mul_out_reg : 0;
        end
    end
endmodule