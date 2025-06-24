module multi_pipe_8bit (
    input wire clk,
    input wire rst_n,
    input wire mul_en_in,
    input wire [7:0] mul_a,
    input wire [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);

reg [7:0] mul_a_reg, mul_b_reg;
reg [15:0] temp [0:7];
reg [15:0] sum [0:3];
reg [15:0] mul_out_reg;
reg [7:0] mul_en_out_reg;

integer i;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_en_out_reg <= 8'b0;
        mul_a_reg <= 8'b0;
        mul_b_reg <= 8'b0;
        mul_out_reg <= 16'b0;
    end else begin
        mul_en_out_reg <= {mul_en_out_reg[6:0], mul_en_in};
        if (mul_en_in) begin
            mul_a_reg <= mul_a;
            mul_b_reg <= mul_b;
        end
    end
end

always @* begin
    for (i = 0; i < 8; i = i + 1) begin
        temp[i] = mul_b_reg[i] ? (mul_a_reg << i) : 16'b0;
    end
end

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
        mul_out <= 16'b0;
        mul_en_out <= 1'b0;
    end else begin
        mul_out <= mul_en_out_reg[7] ? mul_out_reg : 16'b0;
        mul_en_out <= mul_en_out_reg[7];
    end
end

endmodule