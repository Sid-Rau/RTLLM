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
reg [7:0] mul_en_out_reg;
wire [15:0] temp [7:0];
reg [15:0] sum [3:0];
reg [15:0] mul_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
        mul_en_out_reg <= 8'b0;
    end
    else begin
        if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
        mul_en_out_reg <= {mul_en_out_reg[6:0], mul_en_in};
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
        mul_out_reg <= 16'b0;
    end
    else begin
        sum[0] <= temp[0] + temp[1];
        sum[1] <= temp[2] + temp[3];
        sum[2] <= temp[4] + temp[5];
        sum[3] <= temp[6] + temp[7];
        mul_out_reg <= sum[0] + sum[1] + sum[2] + sum[3];
    end
end

always @(*) begin
    mul_en_out = mul_en_out_reg[7];
    mul_out = mul_en_out ? mul_out_reg : 16'b0;
end

endmodule