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
reg [16:0] sum1;
reg [33:0] sum2;
reg [50:0] sum3;
reg carry1, carry2, carry3;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_reg1 <= 0;
        addb_reg1 <= 0;
        i_en_reg1 <= 0;
        adda_reg2 <= 0;
        addb_reg2 <= 0;
        i_en_reg2 <= 0;
        adda_reg3 <= 0;
        addb_reg3 <= 0;
        i_en_reg3 <= 0;
        sum1 <= 0;
        sum2 <= 0;
        sum3 <= 0;
        carry1 <= 0;
        carry2 <= 0;
        carry3 <= 0;
        result <= 0;
        o_en <= 0;
    end else begin
        adda_reg1 <= adda;
        addb_reg1 <= addb;
        i_en_reg1 <= i_en;

        adda_reg2 <= adda_reg1;
        addb_reg2 <= addb_reg1;
        i_en_reg2 <= i_en_reg1;

        adda_reg3 <= adda_reg2;
        addb_reg3 <= addb_reg2;
        i_en_reg3 <= i_en_reg2;

        {carry1, sum1[15:0]} <= adda[15:0] + addb[15:0];
        {carry2, sum2[31:0]} <= {adda_reg1[31:16] + addb_reg1[31:16] + carry1, sum1[15:0]};
        {carry3, sum3[47:0]} <= {adda_reg2[47:32] + addb_reg2[47:32] + carry2, sum2[31:0]};
        result <= {adda_reg3[63:48] + addb_reg3[63:48] + carry3, sum3[47:0]};

        o_en <= i_en_reg3;
    end
end

endmodule