module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);
    parameter size = 4;
    reg [7:0] partial_products [0:size-1];
    reg [7:0] sum_reg [0:size-1];
    reg [7:0] final_sum;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 8'd0;
            final_sum <= 8'd0;
            for (int i = 0; i < size; i = i + 1) begin
                partial_products[i] <= 8'd0;
                sum_reg[i] <= 8'd0;
            end
        end else begin
            for (int i = 0; i < size; i = i + 1) begin
                if (mul_b[i]) begin
                    partial_products[i] <= {mul_a, 4'd0} << i;
                end else begin
                    partial_products[i] <= 8'd0;
                end
            end
            
            final_sum = 8'd0;
            for (int j = 0; j < size; j = j + 1) begin
                sum_reg[j] <= partial_products[j];
                final_sum = final_sum + sum_reg[j];
            end
            
            mul_out <= final_sum;
        end
    end
endmodule