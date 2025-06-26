module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output [64:0] result,
    output o_en
);

// Pipeline registers for inputs
reg [63:0] adda_r0, adda_r1, adda_r2, adda_r3;
reg [63:0] addb_r0, addb_r1, addb_r2, addb_r3;

// Pipeline registers for enable signal
reg en_r0, en_r1, en_r2, en_r3;

// Internal wires for intermediate sums and carries
wire [15:0] sum0_w, sum1_w, sum2_w, sum3_w;
wire c0_w, c1_w, c2_w;

// Pipeline registers for intermediate sums and carries
reg [15:0] sum0_r, sum1_r, sum2_r;
reg c0_r, c1_r, c2_r;

// Output registers
reg [64:0] result_r;
reg o_en_r;

// Input stage (Stage 0)
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_r0 <= 64'b0;
        addb_r0 <= 64'b0;
        en_r0   <= 1'b0;
    end else begin
        adda_r0 <= adda;
        addb_r0 <= addb;
        en_r0   <= i_en;
    end
end

// Stage 1: Add lower 16 bits
assign {c0_w, sum0_w} = adda_r0[15:0] + addb_r0[15:0];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum0_r <= 16'b0;
        c0_r   <= 1'b0;
        adda_r1 <= 64'b0;
        addb_r1 <= 64'b0;
        en_r1   <= 1'b0;
    end else begin
        sum0_r <= sum0_w;
        c0_r   <= c0_w;
        adda_r1 <= adda_r0;
        addb_r1 <= addb_r0;
        en_r1   <= en_r0;
    end
end

// Stage 2: Add next 16 bits
assign {c1_w, sum1_w} = adda_r1[31:16] + addb_r1[31:16] + c0_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum1_r <= 16'b0;
        c1_r   <= 1'b0;
        adda_r2 <= 64'b0;
        addb_r2 <= 64'b0;
        en_r2   <= 1'b0;
    end else begin
        sum1_r <= sum1_w;
        c1_r   <= c1_w;
        adda_r2 <= adda_r1;
        addb_r2 <= addb_r1;
        en_r2   <= en_r1;
    end
end

// Stage 3: Add next 16 bits
assign {c2_w, sum2_w} = adda_r2[47:32] + addb_r2[47:32] + c1_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        sum2_r <= 16'b0;
        c2_r   <= 1'b0;
        adda_r3 <= 64'b0;
        addb_r3 <= 64'b0;
        en_r3   <= 1'b0;
    end else begin
        sum2_r <= sum2_w;
        c2_r   <= c2_w;
        adda_r3 <= adda_r2;
        addb_r3 <= addb_r2;
        en_r3   <= en_r2;
    end
end

// Stage 4: Add upper 16 bits and form final result
assign {result_r[64], result_r[63:48]} = adda_r3[63:48] + addb_r3[63:48] + c2_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        result_r <= 65'b0;
        o_en_r   <= 1'b0;
    end else begin
        result_r[15:0]  <= sum0_r;
        result_r[31:16] <= sum1_r;
        result_r[47:32] <= sum2_r;
        // result_r[64:48] is assigned directly from the wire above
        o_en_r          <= en_r3;
    end
end

assign result = result_r;
assign o_en = o_en_r;

endmodule