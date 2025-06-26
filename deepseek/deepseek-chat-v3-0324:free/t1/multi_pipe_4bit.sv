module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;

reg [7:0] mul_a_ext;
reg [7:0] mul_b_ext;
reg [7:0] partial_products [0:3];
reg [7:0] sum_reg [0:1];

always @* begin
    mul_a_ext = {4'b0, mul_a};
    mul_b_ext = {4'b0, mul_b};
end

genvar i;
generate
    for (i = 0; i < size; i = i + 1) begin : gen_partial_products
        always @* begin
            partial_products[i] = mul_b[i] ? (mul_a_ext << i) : 8'd0;
        end
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_reg[0] <= 8'd0;
        sum_reg[1] <= 8'd0;
    end
    else begin
        sum_reg[0] <= partial_products[0] + partial_products[1];
        sum_reg[1] <= partial_products[2] + partial_products[3];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out <= 8'd0;
    end
    else begin
        mul_out <= sum_reg[0] + sum_reg[1];
    end
end

endmodule