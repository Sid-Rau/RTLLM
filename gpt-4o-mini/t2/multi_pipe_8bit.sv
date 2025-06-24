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
    reg [15:0] partial_products [0:7];
    reg [15:0] sum [0:7];
    reg [15:0] mul_out_reg;
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 0;
            mul_a_reg <= 0;
            mul_b_reg <= 0;
            mul_out_reg <= 0;
        end else begin
            mul_en_out_reg <= mul_en_in;
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end
            mul_en_out <= mul_en_out_reg;
        end
    end

    always @(posedge clk) begin
        if (mul_en_out_reg) begin
            for (i = 0; i < 8; i = i + 1) begin
                partial_products[i] = (mul_a_reg & {8{mul_b_reg[i]}}) << i;
            end
            sum[0] = partial_products[0];
            for (i = 1; i < 8; i = i + 1) begin
                sum[i] = sum[i-1] + partial_products[i];
            end
            mul_out_reg <= sum[7];
        end
    end

    always @(posedge clk) begin
        if (mul_en_out_reg) begin
            mul_out <= mul_out_reg;
        end else begin
            mul_out <= 0;
        end
    end
endmodule