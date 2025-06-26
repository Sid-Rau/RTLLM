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
reg [15:0] temp [0:7];
reg [15:0] sum [0:3];
reg [15:0] sum2 [0:1];
reg [15:0] mul_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
        mul_en_out <= 1'b0;
    end
    else begin
        if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
        mul_en_out <= mul_en_in;
    end
end

always @(*) begin
    temp[0] = mul_b_reg[0] ? {8'b0, mul_a_reg} : 16'b0;
    temp[1] = mul_b_reg[1] ? {7'b0, mul_a_reg, 1'b0} : 16'b0;
    temp[2] = mul_b_reg[2] ? {6'b0, mul_a_reg, 2'b0} : 16'b0;
    temp[3] = mul_b_reg[3] ? {5'b0, mul_a_reg, 3'b0} : 16'b0;
    temp[4] = mul_b_reg[4] ? {4'b0, mul_a_reg, 4'b0} : 16'b0;
    temp[5] = mul_b_reg[5] ? {3'b0, mul_a_reg, 5'b0} : 16'b0;
    temp[6] = mul_b_reg[6] ? {2'b0, mul_a_reg, 6'b0} : 16'b0;
    temp[7] = mul_b_reg[7] ? {1'b0, mul_a_reg, 7'b0} : 16'b0;
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum[0] <= 16'b0;
        sum[1] <= 16'b0;
        sum[2] <= 16'b0;
        sum[3] <= 16'b0;
    end
    else begin
        sum[0] <= temp[0] + temp[1];
        sum[1] <= temp[2] + temp[3];
        sum[2] <= temp[4] + temp[5];
        sum[3] <= temp[6] + temp[7];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum2[0] <= 16'b0;
        sum2[1] <= 16'b0;
    end
    else begin
        sum2[0] <= sum[0] + sum[1];
        sum2[1] <= sum[2] + sum[3];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out_reg <= 16'b0;
    end
    else begin
        mul_out_reg <= sum2[0] + sum2[1];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out <= 16'b0;
    end
    else begin
        mul_out <= mul_en_out ? mul_out_reg : 16'b0;
    end
end

endmodule