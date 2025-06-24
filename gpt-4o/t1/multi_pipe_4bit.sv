module multi_pipe_4bit (
    input wire clk,
    input wire rst_n,
    input wire [3:0] mul_a,
    input wire [3:0] mul_b,
    output reg [7:0] mul_out
);

    reg [7:0] partial_products [0:3];
    reg [7:0] sum_stage1;
    reg [7:0] sum_stage2;

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 4; i = i + 1) begin
                partial_products[i] <= 8'b0;
            end
            sum_stage1 <= 8'b0;
            sum_stage2 <= 8'b0;
            mul_out <= 8'b0;
        end else begin
            for (i = 0; i < 4; i = i + 1) begin
                if (mul_b[i])
                    partial_products[i] <= mul_a << i;
                else
                    partial_products[i] <= 8'b0;
            end

            sum_stage1 <= partial_products[0] + partial_products[1];
            sum_stage2 <= partial_products[2] + partial_products[3];
            mul_out <= sum_stage1 + sum_stage2;
        end
    end

endmodule