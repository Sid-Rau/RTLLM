module multi_pipe_8bit (
    input clk,
    input rst_n,
    input mul_en_in,
    input [7:0] mul_a,
    input [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

reg [7:0] mul_a_reg;
reg [7:0] mul_b_reg;
reg [15:0] mul_out_reg;
reg [15:0] sum [0:3];
reg [15:0] temp [0:7];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
        mul_out_reg <= 16'b0;
        mul_en_out <= 1'b0;
        for (integer i = 0; i < 8; i = i + 1) temp[i] <= 16'b0;
        for (integer j = 0; j < 4; j = j + 1) sum[j] <= 16'b0;
    end
    else begin
        if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
        mul_en_out <= mul_en_in;

        for (integer k = 0; k < 8; k = k + 1) begin
            temp[k] <= mul_b_reg[k] ? {8'b0, mul_a_reg} << k : 16'b0;
        end

        sum[0] <= temp[0] + temp[1];
        sum[1] <= temp[2] + temp[3];
        sum[2] <= temp[4] + temp[5];
        sum[3] <= temp[6] + temp[7];

        mul_out_reg <= sum[0] + sum[1] + sum[2] + sum[3];
    end
end

always @(*) begin
    if (mul_en_out) begin
        mul_out = mul_out_reg;
    end
    else begin
        mul_out = 16'b0;
    end
end

endmodule