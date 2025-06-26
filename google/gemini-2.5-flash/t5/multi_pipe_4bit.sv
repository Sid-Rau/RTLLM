module multi_pipe_4bit #(parameter size = 4) (
    input clk,
    input rst_n,
    input [size-1:0] mul_a,
    input [size-1:0] mul_b,
    output reg [2*size-1:0] mul_out
);

reg [2*size-1:0] mul_a_ext;
reg [2*size-1:0] partial_products [size-1:0];
reg [2*size-1:0] sum_level1;
reg [2*size-1:0] sum_level2;

genvar i;
generate
    for (i = 0; i < size; i = i + 1) begin : gen_partial_products
        always @(*) begin
            if (mul_b[i]) begin
                partial_products[i] = mul_a_ext << i;
            end else begin
                partial_products[i] = {2*size{1'b0}};
            end
        end
    end
endgenerate

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mul_a_ext <= {2*size{1'b0}};
        sum_level1 <= {2*size{1'b0}};
        sum_level2 <= {2*size{1'b0}};
        mul_out <= {2*size{1'b0}};
    end else begin
        mul_a_ext <= {{(2*size-size){1'b0}}, mul_a};

        sum_level1 <= partial_products[0] + partial_products[1] + partial_products[2] + partial_products[3];

        sum_level2 <= sum_level1;

        mul_out <= sum_level2;
    end
end

endmodule