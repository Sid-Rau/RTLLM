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
    reg [15:0] partial_sum [0:7];
    reg [15:0] mul_out_reg;
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 1'b0;
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
            mul_out_reg <= 16'b0;
            mul_en_out <= 1'b0;
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
                partial_sum[i] = mul_a_reg * {8'b0, mul_b_reg[i]};
            end
            mul_out_reg = partial_sum[0] + partial_sum[1] + partial_sum[2] + partial_sum[3] +
                           partial_sum[4] + partial_sum[5] + partial_sum[6] + partial_sum[7];
        end
    end

    always @(posedge clk) begin
        if (mul_en_out_reg) begin
            mul_out <= mul_out_reg;
        end else begin
            mul_out <= 16'b0;
        end
    end
endmodule