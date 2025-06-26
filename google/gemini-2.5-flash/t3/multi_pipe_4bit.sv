module multi_pipe_4bit #(parameter size = 4) (
    input clk,
    input rst_n,
    input [size-1:0] mul_a,
    input [size-1:0] mul_b,
    output reg [2*size-1:0] mul_out
);

reg [2*size-1:0] mul_a_ext;
reg [2*size-1:0] partial_product [size-1:0];
reg [2*size-1:0] sum_reg1;
reg [2*size-1:0] sum_reg2;

genvar i;
generate
    for (i = 0; i < size; i = i + 1) begin : gen_partial_products
        always @(*) begin
            if (mul_b[i] == 1'b1) begin
                partial_product[i] = mul_a_ext << i;
            end else begin
                partial_product[i] = {2*size{1'b0}};
            end
        end
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_ext <= {2*size{1'b0}};
        sum_reg1 <= {2*size{1'b0}};
        sum_reg2 <= {2*size{1'b0}};
        mul_out <= {2*size{1'b0}};
    end else begin
        mul_a_ext <= {{(2*size - size){1'b0}}, mul_a};

        sum_reg1 <= partial_product[0] + partial_product[1];
        sum_reg2 <= partial_product[2] + partial_product[3];

        mul_out <= sum_reg1 + sum_reg2;
    end
end

endmodule