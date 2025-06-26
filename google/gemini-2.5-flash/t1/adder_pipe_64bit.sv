module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output [64:0] result,
    output o_en
);

// Internal pipeline registers for operands
reg [63:0] adda_r0;
reg [63:0] addb_r0;
reg [63:0] adda_r1;
reg [63:0] addb_r1;
reg [63:0] adda_r2;
reg [63:0] addb_r2;
reg [63:0] adda_r3;
reg [63:0] addb_r3;

// Internal pipeline registers for intermediate sums and carries
reg [15:0] sum0_r;
reg c0_r;
reg [15:0] sum1_r;
reg c1_r;
reg [15:0] sum2_r;
reg c2_r;
reg [15:0] sum3_r;
reg c3_r;

// Internal pipeline registers for enable signal
reg en_r0;
reg en_r1;
reg en_r2;
reg en_r3;

// Output registers
reg [64:0] result_reg;
reg o_en_reg;

// Assign outputs from registers
assign result = result_reg;
assign o_en = o_en_reg;

// Pipeline stage 0: Register inputs
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_r0 <= 64'b0;
        addb_r0 <= 64'b0;
        en_r0 <= 1'b0;
    end else begin
        adda_r0 <= adda;
        addb_r0 <= addb;
        en_r0 <= i_en;
    end
end

// Pipeline stage 1: First 16 bits
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum0_r <= 16'b0;
        c0_r <= 1'b0;
        adda_r1 <= 64'b0;
        addb_r1 <= 64'b0;
        en_r1 <= 1'b0;
    end else begin
        {c0_r, sum0_r} <= adda_r0[15:0] + addb_r0[15:0];
        adda_r1 <= adda_r0;
        addb_r1 <= addb_r0;
        en_r1 <= en_r0;
    end
end

// Pipeline stage 2: Next 16 bits
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum1_r <= 16'b0;
        c1_r <= 1'b0;
        adda_r2 <= 64'b0;
        addb_r2 <= 64'b0;
        en_r2 <= 1'b0;
    end else begin
        {c1_r, sum1_r} <= adda_r1[31:16] + addb_r1[31:16] + c0_r;
        adda_r2 <= adda_r1;
        addb_r2 <= addb_r1;
        en_r2 <= en_r1;
    end
end

// Pipeline stage 3: Next 16 bits
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum2_r <= 16'b0;
        c2_r <= 1'b0;
        adda_r3 <= 64'b0;
        addb_r3 <= 64'b0;
        en_r3 <= 1'b0;
    end else begin
        {c2_r, sum2_r} <= adda_r2[47:32] + addb_r2[47:32] + c1_r;
        adda_r3 <= adda_r2;
        addb_r3 <= addb_r2;
        en_r3 <= en_r2;
    end
end

// Pipeline stage 4: Last 16 bits and final result assembly
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum3_r <= 16'b0;
        c3_r <= 1'b0;
        result_reg <= 65'b0;
        o_en_reg <= 1'b0;
    end else begin
        {c3_r, sum3_r} <= adda_r3[63:48] + addb_r3[63:48] + c2_r;
        result_reg <= {c3_r, sum3_r, sum2_r, sum1_r, sum0_r};
        o_en_reg <= en_r3;
    end
end

endmodule