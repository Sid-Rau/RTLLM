module multi_pipe_4bit(
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);
    parameter size = 4;
    reg [7:0] partial_product [0:size-1];
    reg [7:0] sum_reg [0:size-1];
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 8'd0;
            for (i = 0; i < size; i = i + 1) begin
                partial_product[i] <= 8'd0;
                sum_reg[i] <= 8'd0;
            end
        end else begin
            for (i = 0; i < size; i = i + 1) begin
                if (mul_b[i]) begin
                    partial_product[i] <= {mul_a, 4'b0} << i;
                end else begin
                    partial_product[i] <= 8'd0;
                end
                sum_reg[i] <= sum_reg[i] + partial_product[i];
            end
            mul_out <= sum_reg[0] + sum_reg[1] + sum_reg[2] + sum_reg[3];
        end
    end
endmodule