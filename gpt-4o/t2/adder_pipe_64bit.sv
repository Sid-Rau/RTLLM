module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output reg [64:0] result,
    output reg o_en
);

reg [63:0] reg_adda_stage1, reg_addb_stage1;
reg [63:0] reg_adda_stage2, reg_addb_stage2;
reg [63:0] reg_adda_stage3, reg_addb_stage3;
reg [63:0] reg_adda_stage4, reg_addb_stage4;
reg [64:0] sum_stage1, sum_stage2, sum_stage3, sum_stage4;
reg en_stage1, en_stage2, en_stage3, en_stage4;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_adda_stage1 <= 64'b0;
        reg_addb_stage1 <= 64'b0;
        en_stage1 <= 1'b0;
    end else if (i_en) begin
        reg_adda_stage1 <= adda;
        reg_addb_stage1 <= addb;
        en_stage1 <= i_en;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_stage1 <= 65'b0;
    end else if (en_stage1) begin
        sum_stage1 <= {1'b0, reg_adda_stage1} + {1'b0, reg_addb_stage1};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_adda_stage2 <= 64'b0;
        reg_addb_stage2 <= 64'b0;
        en_stage2 <= 1'b0;
    end else begin
        reg_adda_stage2 <= sum_stage1[63:0];
        reg_addb_stage2 <= sum_stage1[64];
        en_stage2 <= en_stage1;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_stage2 <= 65'b0;
    end else if (en_stage2) begin
        sum_stage2 <= {1'b0, reg_adda_stage2} + {64'b0, reg_addb_stage2};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_adda_stage3 <= 64'b0;
        reg_addb_stage3 <= 64'b0;
        en_stage3 <= 1'b0;
    end else begin
        reg_adda_stage3 <= sum_stage2[63:0];
        reg_addb_stage3 <= sum_stage2[64];
        en_stage3 <= en_stage2;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_stage3 <= 65'b0;
    end else if (en_stage3) begin
        sum_stage3 <= {1'b0, reg_adda_stage3} + {64'b0, reg_addb_stage3};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        reg_adda_stage4 <= 64'b0;
        reg_addb_stage4 <= 64'b0;
        en_stage4 <= 1'b0;
    end else begin
        reg_adda_stage4 <= sum_stage3[63:0];
        reg_addb_stage4 <= sum_stage3[64];
        en_stage4 <= en_stage3;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_stage4 <= 65'b0;
    end else if (en_stage4) begin
        sum_stage4 <= {1'b0, reg_adda_stage4} + {64'b0, reg_addb_stage4};
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result <= 65'b0;
        o_en <= 1'b0;
    end else begin
        result <= sum_stage4;
        o_en <= en_stage4;
    end
end

endmodule