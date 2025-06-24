module adder_pipe_64bit(
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

    reg [63:0] reg_adda_stage1, reg_addb_stage1;
    reg [64:0] sum_stage1;
    reg en_stage1;

    reg [64:0] reg_sum_stage2;
    reg en_stage2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_adda_stage1 <= 64'b0;
            reg_addb_stage1 <= 64'b0;
            sum_stage1 <= 65'b0;
            en_stage1 <= 1'b0;
        end else if (i_en) begin
            reg_adda_stage1 <= adda;
            reg_addb_stage1 <= addb;
            sum_stage1 <= {1'b0, adda} + {1'b0, addb};
            en_stage1 <= i_en;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_sum_stage2 <= 65'b0;
            en_stage2 <= 1'b0;
        end else begin
            reg_sum_stage2 <= sum_stage1;
            en_stage2 <= en_stage1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 65'b0;
            o_en <= 1'b0;
        end else begin
            result <= reg_sum_stage2;
            o_en <= en_stage2;
        end
    end

endmodule