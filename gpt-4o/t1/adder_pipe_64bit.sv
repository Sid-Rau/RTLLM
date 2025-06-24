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
    reg [64:0] sum1, sum2, sum3;
    reg i_en_reg1, i_en_reg2, i_en_reg3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg1 <= 64'd0;
            addb_reg1 <= 64'd0;
            sum1 <= 65'd0;
            i_en_reg1 <= 1'b0;
        end else begin
            adda_reg1 <= adda;
            addb_reg1 <= addb;
            sum1 <= {1'b0, adda} + {1'b0, addb};
            i_en_reg1 <= i_en;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg2 <= 64'd0;
            addb_reg2 <= 64'd0;
            sum2 <= 65'd0;
            i_en_reg2 <= 1'b0;
        end else begin
            adda_reg2 <= adda_reg1;
            addb_reg2 <= addb_reg1;
            sum2 <= sum1;
            i_en_reg2 <= i_en_reg1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            adda_reg3 <= 64'd0;
            addb_reg3 <= 64'd0;
            sum3 <= 65'd0;
            i_en_reg3 <= 1'b0;
        end else begin
            adda_reg3 <= adda_reg2;
            addb_reg3 <= addb_reg2;
            sum3 <= sum2;
            i_en_reg3 <= i_en_reg2;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 65'd0;
            o_en <= 1'b0;
        end else begin
            result <= sum3;
            o_en <= i_en_reg3;
        end
    end

endmodule