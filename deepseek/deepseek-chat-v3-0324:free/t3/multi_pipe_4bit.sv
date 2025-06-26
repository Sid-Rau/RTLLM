module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;
reg [7:0] extended_a;
reg [7:0] extended_b;
reg [7:0] partial_products [0:3];
reg [7:0] sum_stage1 [0:1];
reg [7:0] sum_stage2;

always @(*) begin
    extended_a = {4'b0, mul_a};
    extended_b = {4'b0, mul_b};
end

genvar i;
generate
    for (i = 0; i < size; i = i + 1) begin : gen_partial_products
        always @(*) begin
            if (mul_b[i]) begin
                partial_products[i] = extended_a << i;
            end else begin
                partial_products[i] = 8'd0;
            end
        end
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_stage1[0] <= 8'd0;
        sum_stage1[1] <= 8'd0;
        sum_stage2 <= 8'd0;
        mul_out <= 8'd0;
    end else begin
        sum_stage1[0] <= partial_products[0] + partial_products[1];
        sum_stage1[1] <= partial_products[2] + partial_products[3];
        sum_stage2 <= sum_stage1[0] + sum_stage1[1];
        mul_out <= sum_stage2;
    end
end

endmodule