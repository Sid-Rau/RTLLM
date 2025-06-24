module multi_pipe_4bit #(parameter size = 4)(
    input wire clk,
    input wire rst_n,
    input wire [size-1:0] mul_a,
    input wire [size-1:0] mul_b,
    output reg [2*size-1:0] mul_out
);

    reg [2*size-1:0] partial_sum [0:size-1];
    reg [2*size-1:0] shift_mul_a [0:size-1];
    reg [2*size-1:0] sum_reg1;
    reg [2*size-1:0] sum_reg2;

    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg1 <= 0;
            sum_reg2 <= 0;
        end else begin
            for (i = 0; i < size; i = i + 1) begin
                shift_mul_a[i] <= {mul_a, {size{1'b0}}} << i;
                partial_sum[i] <= mul_b[i] ? shift_mul_a[i] : 0;
            end

            sum_reg1 <= partial_sum[0] + partial_sum[1];
            sum_reg2 <= partial_sum[2] + partial_sum[3];
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_out <= 0;
        end else begin
            mul_out <= sum_reg1 + sum_reg2;
        end
    end

endmodule