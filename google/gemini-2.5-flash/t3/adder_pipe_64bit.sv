module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output [64:0] result,
    output o_en
);

// Internal registers for pipeline stages
reg [63:0] adda_r0;
reg [63:0] addb_r0;
reg i_en_r0;

reg [63:0] adda_r1;
reg [63:0] addb_r1;
reg i_en_r1;
reg [64:0] sum_r1;

reg [64:0] sum_r2;
reg i_en_r2;

// Pipeline stage 0: Register inputs
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_r0 <= 64'd0;
        addb_r0 <= 64'd0;
        i_en_r0 <= 1'b0;
    end else begin
        adda_r0 <= adda;
        addb_r0 <= addb;
        i_en_r0 <= i_en;
    end
end

// Pipeline stage 1: Perform addition, register inputs from stage 0
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_r1 <= 64'd0;
        addb_r1 <= 64'd0;
        i_en_r1 <= 1'b0;
        sum_r1 <= 65'd0;
    end else begin
        adda_r1 <= adda_r0;
        addb_r1 <= addb_r0;
        i_en_r1 <= i_en_r0;
        sum_r1 <= {1'b0, adda_r0} + {1'b0, addb_r0}; // 64-bit sum can be 65-bit
    end
end

// Pipeline stage 2: Register sum and enable from stage 1
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum_r2 <= 65'd0;
        i_en_r2 <= 1'b0;
    end else begin
        sum_r2 <= sum_r1;
        i_en_r2 <= i_en_r1;
    end
end

// Output assignments
assign result = sum_r2;
assign o_en = i_en_r2;

endmodule