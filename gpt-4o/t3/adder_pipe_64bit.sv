module adder_pipe_64bit(
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

    reg [63:0] adda_reg1, adda_reg2, adda_reg3;
    reg [63:0] addb_reg1, addb_reg2, addb_reg3;
    reg i_en_reg1, i_en_reg2, i_en_reg3;
    reg [64:0] sum_stage1, sum_stage2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg1 <= 64'b0;
            addb_reg1 <= 64'b0;
            i_en_reg1 <= 1'b0;
            sum_stage1 <= 65'b0;
        end else begin
            adda_reg1 <= adda;
            addb_reg1 <= addb;
            i_en_reg1 <= i_en;
            if (i_en_reg1) begin
                sum_stage1 <= {1'b0, adda_reg1} + {1'b0, addb_reg1};
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg2 <= 64'b0;
            addb_reg2 <= 64'b0;
            i_en_reg2 <= 1'b0;
            sum_stage2 <= 65'b0;
        end else begin
            adda_reg2 <= adda_reg1;
            addb_reg2 <= addb_reg1;
            i_en_reg2 <= i_en_reg1;
            if (i_en_reg2) begin
                sum_stage2 <= sum_stage1;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg3 <= 64'b0;
            addb_reg3 <= 64'b0;
            i_en_reg3 <= 1'b0;
            result <= 65'b0;
            o_en <= 1'b0;
        end else begin
            adda_reg3 <= adda_reg2;
            addb_reg3 <= addb_reg2;
            i_en_reg3 <= i_en_reg2;
            if (i_en_reg3) begin
                result <= sum_stage2;
                o_en <= 1'b1;
            end else begin
                o_en <= 1'b0;
            end
        end
    end

endmodule