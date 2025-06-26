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
reg [64:0] sum1, sum2;
reg [64:0] carry1, carry2;
reg i_en_reg1, i_en_reg2, i_en_reg3;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_reg1 <= 64'b0;
        adda_reg2 <= 64'b0;
        adda_reg3 <= 64'b0;
        addb_reg1 <= 64'b0;
        addb_reg2 <= 64'b0;
        addb_reg3 <= 64'b0;
        sum1 <= 65'b0;
        sum2 <= 65'b0;
        carry1 <= 65'b0;
        carry2 <= 65'b0;
        i_en_reg1 <= 1'b0;
        i_en_reg2 <= 1'b0;
        i_en_reg3 <= 1'b0;
        o_en <= 1'b0;
        result <= 65'b0;
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

        sum1 <= {1'b0, adda_reg1[31:0]} + {1'b0, addb_reg1[31:0]};
        carry1 <= {1'b0, adda_reg1[63:32]} + {1'b0, addb_reg1[63:32]} + sum1[32];
        sum2 <= sum1;
        carry2 <= carry1;
        result <= {carry2[32:0], sum2[31:0]};
    end
end

endmodule