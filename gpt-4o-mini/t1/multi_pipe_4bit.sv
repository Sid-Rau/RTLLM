module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);
    parameter size = 4;
    reg [7:0] partial_products [0:size-1];
    reg [7:0] sum;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            partial_products[0] <= 0;
            partial_products[1] <= 0;
            partial_products[2] <= 0;
            partial_products[3] <= 0;
            sum <= 0;
            mul_out <= 0;
        end else begin
            partial_products[0] <= (mul_b[0] ? {4'b0000, mul_a} : 8'b0);
            partial_products[1] <= (mul_b[1] ? {3'b000, mul_a, 1'b0} : 8'b0);
            partial_products[2] <= (mul_b[2] ? {2'b00, mul_a, 2'b00} : 8'b0);
            partial_products[3] <= (mul_b[3] ? {1'b0, mul_a, 3'b000} : 8'b0);
            
            sum <= partial_products[0] + partial_products[1] + partial_products[2] + partial_products[3];
            mul_out <= sum;
        end
    end
endmodule