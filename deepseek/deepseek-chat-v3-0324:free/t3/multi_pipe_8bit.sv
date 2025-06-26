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
reg [15:0] sum [0:7];
wire [15:0] temp [0:7];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
        mul_en_out <= 1'b0;
        mul_out_reg <= 16'b0;
    end
    else begin
        if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
        mul_en_out <= mul_en_in;
        mul_out_reg <= sum[7];
    end
end

genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : partial_products
        assign temp[i] = mul_b_reg[i] ? (mul_a_reg << i) : 16'b0;
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum[0] <= 16'b0;
        sum[1] <= 16'b0;
        sum[2] <= 16'b0;
        sum[3] <= 16'b0;
        sum[4] <= 16'b0;
        sum[5] <= 16'b0;
        sum[6] <= 16'b0;
        sum[7] <= 16'b0;
    end
    else begin
        sum[0] <= temp[0];
        sum[1] <= sum[0] + temp[1];
        sum[2] <= sum[1] + temp[2];
        sum[3] <= sum[2] + temp[3];
        sum[4] <= sum[3] + temp[4];
        sum[5] <= sum[4] + temp[5];
        sum[6] <= sum[5] + temp[6];
        sum[7] <= sum[6] + temp[7];
    end
end

always @(*) begin
    if (mul_en_out)
        mul_out = mul_out_reg;
    else
        mul_out = 16'b0;
end

endmodule