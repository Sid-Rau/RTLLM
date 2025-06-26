module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output [64:0] result,
    output o_en
);

// Pipeline registers for inputs and enable signal
reg [63:0] adda_p0, addb_p0;
reg i_en_p0;

reg [63:0] adda_p1, addb_p1;
reg i_en_p1;

reg [63:0] adda_p2, addb_p2;
reg i_en_p2;

reg [63:0] adda_p3, addb_p3;
reg i_en_p3;

// Pipeline registers for intermediate sums and carries
reg [15:0] sum0_p0;
reg c_in1_p0;

reg [15:0] sum1_p1;
reg c_in2_p1;

reg [15:0] sum2_p2;
reg c_in3_p2;

reg [15:0] sum3_p3;
reg c_out_p3;

// Output registers
reg [64:0] result_reg;
reg o_en_reg;

// Combinational logic for each stage
wire [15:0] sum0_comb;
wire c_in1_comb;

wire [15:0] sum1_comb;
wire c_in2_comb;

wire [15:0] sum2_comb;
wire c_in3_comb;

wire [15:0] sum3_comb;
wire c_out_comb;

assign {c_in1_comb, sum0_comb} = adda_p0[15:0] + addb_p0[15:0];
assign {c_in2_comb, sum1_comb} = adda_p1[31:16] + addb_p1[31:16] + c_in1_p0;
assign {c_in3_comb, sum2_comb} = adda_p2[47:32] + addb_p2[47:32] + c_in2_p1;
assign {c_out_comb, sum3_comb} = adda_p3[63:48] + addb_p3[63:48] + c_in3_p2;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // Reset all pipeline registers
        adda_p0 <= 64'b0;
        addb_p0 <= 64'b0;
        i_en_p0 <= 1'b0;

        adda_p1 <= 64'b0;
        addb_p1 <= 64'b0;
        i_en_p1 <= 1'b0;

        adda_p2 <= 64'b0;
        addb_p2 <= 64'b0;
        i_en_p2 <= 1'b0;

        adda_p3 <= 64'b0;
        addb_p3 <= 64'b0;
        i_en_p3 <= 1'b0;

        sum0_p0 <= 16'b0;
        c_in1_p0 <= 1'b0;

        sum1_p1 <= 16'b0;
        c_in2_p1 <= 1'b0;

        sum2_p2 <= 16'b0;
        c_in3_p2 <= 1'b0;

        sum3_p3 <= 16'b0;
        c_out_p3 <= 1'b0;

        result_reg <= 65'b0;
        o_en_reg <= 1'b0;
    end else begin
        // Stage 0: Input capture
        adda_p0 <= adda;
        addb_p0 <= addb;
        i_en_p0 <= i_en;

        // Stage 1: First 16-bit addition
        adda_p1 <= adda_p0;
        addb_p1 <= addb_p0;
        i_en_p1 <= i_en_p0;
        sum0_p0 <= sum0_comb;
        c_in1_p0 <= c_in1_comb;

        // Stage 2: Second 16-bit addition
        adda_p2 <= adda_p1;
        addb_p2 <= addb_p1;
        i_en_p2 <= i_en_p1;
        sum1_p1 <= sum1_comb;
        c_in2_p1 <= c_in2_comb;

        // Stage 3: Third 16-bit addition
        adda_p3 <= adda_p2;
        addb_p3 <= addb_p2;
        i_en_p3 <= i_en_p2;
        sum2_p2 <= sum2_comb;
        c_in3_p2 <= c_in3_comb;

        // Stage 4: Fourth 16-bit addition and final result
        sum3_p3 <= sum3_comb;
        c_out_p3 <= c_out_comb;
        
        result_reg <= {c_out_comb, sum3_comb, sum2_p2, sum1_p1, sum0_p0};
        o_en_reg <= i_en_p3;
    end
end

assign result = result_reg;
assign o_en = o_en_reg;

endmodule