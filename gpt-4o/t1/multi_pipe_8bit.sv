module multi_pipe_8bit (
    input wire clk,
    input wire rst_n,
    input wire mul_en_in,
    input wire [7:0] mul_a,
    input wire [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

reg [7:0] mul_a_reg;
reg [7:0] mul_b_reg;
reg [15:0] mul_out_reg;
reg [7:0] mul_en_out_reg;
wire [15:0] temp[7:0];
reg [15:0] sum[3:0];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
        mul_en_out_reg <= 8'b0;
    end else if (mul_en_in) begin
        mul_a_reg <= mul_a;
        mul_b_reg <= mul_b;
        mul_en_out_reg <= {mul_en_out_reg[6:0], mul_en_in};
    end
end

assign temp[0] = mul_b_reg[0] ? {8'b0, mul_a_reg} : 16'b0;
assign temp[1] = mul_b_reg[1] ? {7'b0, mul_a_reg, 1'b0} : 16'b0;
assign temp[2] = mul_b_reg[2] ? {6'b0, mul_a_reg, 2'b0} : 16'b0;
assign temp[3] = mul_b_reg[3] ? {5'b0, mul_a_reg, 3'b0} : 16'b0;
assign temp[4] = mul_b_reg[4] ? {4'b0, mul_a_reg, 4'b0} : 16'b0;
assign temp[5] = mul_b_reg[5] ? {3'b0, mul_a_reg, 5'b0} : 16'b0;
assign temp[6] = mul_b_reg[6] ? {2'b0, mul_a_reg, 6'b0} : 16'b0;
assign temp[7] = mul_b_reg[7] ? {1'b0, mul_a_reg, 7'b0} : 16'b0;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum[0] <= 16'b0;
        sum[1] <= 16'b0;
        sum[2] <= 16'b0;
        sum[3] <= 16'b0;
    end else begin
        sum[0] <= temp[0] + temp[1];
        sum[1] <= temp[2] + temp[3];
        sum[2] <= temp[4] + temp[5];
        sum[3] <= temp[6] + temp[7];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out_reg <= 16'b0;
    end else begin
        mul_out_reg <= sum[0] + sum[1] + sum[2] + sum[3];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_en_out <= 1'b0;
    end else begin
        mul_en_out <= mul_en_out_reg[7];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out <= 16'b0;
    end else if (mul_en_out) begin
        mul_out <= mul_out_reg;
    end else begin
        mul_out <= 16'b0;
    end
end

endmodule