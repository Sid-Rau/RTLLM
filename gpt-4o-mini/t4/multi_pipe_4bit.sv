module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);
    parameter size = 4;
    reg [7:0] partial_product [0:size-1];
    reg [7:0] sum;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 8'b0;
            sum <= 8'b0;
        end else begin
            sum <= 8'b0;
            for (int i = 0; i < size; i++) begin
                if (mul_b[i]) begin
                    partial_product[i] <= {mul_a, 4'b0} << i;
                end else begin
                    partial_product[i] <= 8'b0;
                end
                sum <= sum + partial_product[i];
            end
            mul_out <= sum;
        end
    end
endmodule