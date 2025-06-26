module multi_pipe_8bit (
    input wire clk,
    input wire rst_n,
    input wire mul_en_in,
    input wire [7:0] mul_a,
    input wire [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);
    reg mul_en_out_reg;
    reg [7:0] mul_a_reg, mul_b_reg;
    reg [15:0] partial_products [0:7];
    reg [15:0] sum [0:3];
    reg [15:0] mul_out_reg;

    integer i;

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

            for (i = 0; i < 8; i = i + 1) begin
                partial_products[i] = (mul_b_reg[i] ? {8'b0, mul_a_reg} : 16'b0) << i;
            end

            sum[0] = partial_products[0] + partial_products[1];
            sum[1] = partial_products[2] + partial_products[3];
            sum[2] = partial_products[4] + partial_products[5];
            sum[3] = partial_products[6] + partial_products[7];

            mul_out_reg = sum[0] + sum[1] + sum[2] + sum[3];

            if (mul_en_out_reg) begin
                mul_out <= mul_out_reg;
            end else begin
                mul_out <= 0;
            end
        end
    end
endmodule