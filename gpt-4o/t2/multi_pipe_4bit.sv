module multi_pipe_4bit (
    input clk,
    input rst_n,
    input [3:0] mul_a,
    input [3:0] mul_b,
    output reg [7:0] mul_out
);

    reg [7:0] partial_sum1, partial_sum2;
    reg [7:0] pp0, pp1, pp2, pp3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            partial_sum1 <= 8'b0;
            partial_sum2 <= 8'b0;
            mul_out <= 8'b0;
        end else begin
            pp0 <= mul_b[0] ? {4'b0, mul_a} : 8'b0;
            pp1 <= mul_b[1] ? {3'b0, mul_a, 1'b0} : 8'b0;
            pp2 <= mul_b[2] ? {2'b0, mul_a, 2'b0} : 8'b0;
            pp3 <= mul_b[3] ? {1'b0, mul_a, 3'b0} : 8'b0;

            partial_sum1 <= pp0 + pp1;
            partial_sum2 <= pp2 + pp3;
            mul_out <= partial_sum1 + partial_sum2;
        end
    end

endmodule