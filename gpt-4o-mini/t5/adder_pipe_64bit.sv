module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);
    reg [63:0] a_reg, b_reg;
    reg [64:0] sum_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg <= 64'b0;
            b_reg <= 64'b0;
            sum_reg <= 65'b0;
            o_en <= 1'b0;
        end else if (i_en) begin
            a_reg <= adda;
            b_reg <= addb;
            sum_reg <= a_reg + b_reg;
            o_en <= 1'b1;
        end else begin
            result <= sum_reg;
            o_en <= 1'b0;
        end
    end

    always @(posedge clk) begin
        if (o_en) begin
            result <= sum_reg;
        end
    end
endmodule