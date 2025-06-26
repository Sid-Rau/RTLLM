module multi_pipe_4bit #(parameter size = 4)
(
    input wire clk,
    input wire rst_n,
    input wire [size-1:0] mul_a,
    input wire [size-1:0] mul_b,
    output reg [2*size-1:0] mul_out
);

reg [2*size-1:0] partial_product [size-1:0];
reg [2*size-1:0] sum_level1;
reg [2*size-1:0] sum_level2;

genvar i;
generate
    for (i = 0; i < size; i = i + 1) begin : gen_partial_products
        always @(*) begin
            if (mul_b[i] == 1'b1) begin
                partial_product[i] = {{(2*size-size){1'b0}}, mul_a} << i;
            end else begin
                partial_product[i] = 'd0;
            end
        end
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_level1 <= 'd0;
    end else begin
        sum_level1 <= partial_product[0] + partial_product[1];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_level2 <= 'd0;
    end else begin
        sum_level2 <= partial_product[2] + partial_product[3];
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_out <= 'd0;
    end else begin
        mul_out <= sum_level1 + sum_level2;
    end
end

endmodule