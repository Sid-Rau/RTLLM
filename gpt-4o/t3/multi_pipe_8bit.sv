module multi_pipe_8bit(
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

    reg [7:0] mul_a_reg, mul_b_reg;
    reg [15:0] temp[0:7];
    reg [15:0] sum[0:7];
    reg [7:0] mul_en_out_reg;

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 8'b0;
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
            for (i = 0; i < 8; i = i + 1) begin
                temp[i] <= 16'b0;
                sum[i] <= 16'b0;
            end
            mul_out <= 16'b0;
            mul_en_out <= 1'b0;
        end else begin
            mul_en_out_reg <= {mul_en_out_reg[6:0], mul_en_in};
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
                for (i = 0; i < 8; i = i + 1) begin
                    temp[i] <= (mul_b_reg[i]) ? (mul_a_reg << i) : 16'b0;
                end
                sum[0] <= temp[0];
                for (i = 1; i < 8; i = i + 1) begin
                    sum[i] <= sum[i-1] + temp[i];
                end
                mul_out <= sum[7];
            end
            mul_en_out <= mul_en_out_reg[7];
        end
    end

endmodule