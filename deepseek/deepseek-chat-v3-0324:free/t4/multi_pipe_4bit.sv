module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

parameter size = 4;

wire [7:0] mul_a_ext = {4'b0, mul_a};
wire [7:0] mul_b_ext = {4'b0, mul_b};
wire [7:0] partial_products [0:3];
reg [7:0] sum_reg1;
reg [7:0] sum_reg2;

genvar i;
generate
    for (i = 0; i < size; i = i + 1) begin : gen_partial_products
        assign partial_products[i] = mul_b_ext[i] ? (mul_a_ext << i) : 8'd0;
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_reg1 <= 8'd0;
        sum_reg2 <= 8'd0;
        mul_out <= 8'd0;
    end
    else begin
        sum_reg1 <= partial_products[0] + partial_products[1];
        sum_reg2 <= partial_products[2] + partial_products[3];
        mul_out <= sum_reg1 + sum_reg2;
    end
end

endmodule