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
reg [16:0] sum1;
reg [33:0] sum2;
reg [50:0] sum3;
reg i_en_reg1, i_en_reg2, i_en_reg3;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_reg1 <= 0;
        adda_reg2 <= 0;
        adda_reg3 <= 0;
        addb_reg1 <= 0;
        addb_reg2 <= 0;
        addb_reg3 <= 0;
        sum1 <= 0;
        sum2 <= 0;
        sum3 <= 0;
        i_en_reg1 <= 0;
        i_en_reg2 <= 0;
        i_en_reg3 <= 0;
        o_en <= 0;
        result <= 0;
    end
    else begin
        adda_reg1 <= adda;
        adda_reg2 <= adda_reg1;
        adda_reg3 <= adda_reg2;
        addb_reg1 <= addb;
        addb_reg2 <= addb_reg1;
        addb_reg3 <= addb_reg2;
        i_en_reg1 <= i_en;
        i_en_reg2 <= i_en_reg1;
        i_en_reg3 <= i_en_reg2;
        o_en <= i_en_reg3;

        sum1 <= adda[16:0] + addb[16:0];
        sum2 <= {adda_reg1[33:17] + addb_reg1[33:17] + sum1[16], sum1[15:0]};
        sum3 <= {adda_reg2[50:34] + addb_reg2[50:34] + sum2[33], sum2[32:0]};
        result <= {adda_reg3[63:51] + addb_reg3[63:51] + sum3[50], sum3[49:0]};
    end
end

endmodule