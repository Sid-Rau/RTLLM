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
reg [31:0] sum_low;
reg [32:0] sum_mid;
reg [32:0] sum_high;
reg i_en_reg1, i_en_reg2, i_en_reg3;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_reg1 <= 64'b0;
        addb_reg1 <= 64'b0;
        adda_reg2 <= 64'b0;
        addb_reg2 <= 64'b0;
        adda_reg3 <= 64'b0;
        addb_reg3 <= 64'b0;
        sum_low <= 32'b0;
        sum_mid <= 33'b0;
        sum_high <= 33'b0;
        i_en_reg1 <= 1'b0;
        i_en_reg2 <= 1'b0;
        i_en_reg3 <= 1'b0;
        o_en <= 1'b0;
        result <= 65'b0;
    end
    else begin
        adda_reg1 <= adda;
        addb_reg1 <= addb;
        adda_reg2 <= adda_reg1;
        addb_reg2 <= addb_reg1;
        adda_reg3 <= adda_reg2;
        addb_reg3 <= addb_reg2;

        sum_low <= adda_reg1[31:0] + addb_reg1[31:0];
        sum_mid <= {1'b0, adda_reg2[63:32]} + {1'b0, addb_reg2[63:32]} + sum_low[32];
        sum_high <= {1'b0, adda_reg3[63:32]} + {1'b0, addb_reg3[63:32]} + sum_mid[32];

        i_en_reg1 <= i_en;
        i_en_reg2 <= i_en_reg1;
        i_en_reg3 <= i_en_reg2;
        o_en <= i_en_reg3;

        result <= {sum_high[31:0], sum_low[31:0]};
    end
end

endmodule