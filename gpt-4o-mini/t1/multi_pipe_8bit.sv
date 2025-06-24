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
reg [7:0] mul_a_reg;
reg [7:0] mul_b_reg;
reg [15:0] partial_products [0:7];
reg [15:0] sum [0:7];
reg [15:0] mul_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_en_out_reg <= 1'b0;
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
    end else begin
        mul_en_out_reg <= mul_en_in;
        if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
    end
end

always @(*) begin
    partial_products[0] = mul_a_reg & {8{mul_b_reg[0]}};
    partial_products[1] = mul_a_reg & {8{mul_b_reg[1]}};
    partial_products[2] = mul_a_reg & {8{mul_b_reg[2]}};
    partial_products[3] = mul_a_reg & {8{mul_b_reg[3]}};
    partial_products[4] = mul_a_reg & {8{mul_b_reg[4]}};
    partial_products[5] = mul_a_reg & {8{mul_b_reg[5]}};
    partial_products[6] = mul_a_reg & {8{mul_b_reg[6]}};
    partial_products[7] = mul_a_reg & {8{mul_b_reg[7]}};
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out_reg <= 16'b0;
        mul_en_out <= 1'b0;
    end else begin
        sum[0] <= partial_products[0];
        sum[1] <= partial_products[0] + partial_products[1];
        sum[2] <= sum[1] + partial_products[2];
        sum[3] <= sum[2] + partial_products[3];
        sum[4] <= sum[3] + partial_products[4];
        sum[5] <= sum[4] + partial_products[5];
        sum[6] <= sum[5] + partial_products[6];
        sum[7] <= sum[6] + partial_products[7];
        mul_out_reg <= sum[7];
        mul_en_out <= mul_en_out_reg;
    end
end

always @(*) begin
    if (mul_en_out) begin
        mul_out = mul_out_reg;
    end else begin
        mul_out = 16'b0;
    end
end

endmodule