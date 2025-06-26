module adder_pipe_64bit (
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
    reg [16:0] sum_stage1;
    reg [33:0] sum_stage2;
    reg [50:0] sum_stage3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg1 <= 0;
            addb_reg1 <= 0;
            adda_reg2 <= 0;
            addb_reg2 <= 0;
            adda_reg3 <= 0;
            addb_reg3 <= 0;
            i_en_reg1 <= 0;
            i_en_reg2 <= 0;
            i_en_reg3 <= 0;
            sum_stage1 <= 0;
            sum_stage2 <= 0;
            sum_stage3 <= 0;
            result <= 0;
            o_en <= 0;
        end else begin
            adda_reg1 <= adda;
            addb_reg1 <= addb;
            i_en_reg1 <= i_en;

            adda_reg2 <= adda_reg1;
            addb_reg2 <= addb_reg1;
            i_en_reg2 <= i_en_reg1;
            sum_stage1 <= adda_reg1[15:0] + addb_reg1[15:0];

            adda_reg3 <= adda_reg2;
            addb_reg3 <= addb_reg2;
            i_en_reg3 <= i_en_reg2;
            sum_stage2 <= {adda_reg2[31:16] + addb_reg2[31:16] + sum_stage1[16], sum_stage1[15:0]};

            result <= {adda_reg3[63:32] + addb_reg3[63:32] + sum_stage2[33], sum_stage2[32:0]};
            o_en <= i_en_reg3;
        end
    end

endmodule