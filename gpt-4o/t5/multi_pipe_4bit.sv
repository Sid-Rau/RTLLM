module multi_pipe_4bit #(parameter size = 4)(
    input clk,
    input rst_n,
    input [size-1:0] mul_a,
    input [size-1:0] mul_b,
    output reg [2*size-1:0] mul_out
);

reg [2*size-1:0] partial_product [size-1:0];
reg [2*size-1:0] sum1, sum2;

integer i;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum1 <= 0;
        sum2 <= 0;
        mul_out <= 0;
    end else begin
        for (i = 0; i < size; i = i + 1) begin
            if (mul_b[i])
                partial_product[i] <= mul_a << i;
            else
                partial_product[i] <= 0;
        end

        sum1 <= partial_product[0] + partial_product[1];
        sum2 <= partial_product[2] + partial_product[3];
        mul_out <= sum1 + sum2;
    end
end

endmodule