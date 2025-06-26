module adder_pipe_64bit (
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output [64:0] result,
    output o_en
);

localparam STAGES = 4; // Example number of pipeline stages, can be adjusted

reg [63:0] adda_r [STAGES-1:0];
reg [63:0] addb_r [STAGES-1:0];
reg [STAGES-1:0] en_r;

reg [64:0] sum_r [STAGES-1:0];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        adda_r[0] <= 64'd0;
        addb_r[0] <= 64'd0;
        en_r[0] <= 1'b0;
        sum_r[0] <= 65'd0;
        
        for (int i = 1; i < STAGES; i++) begin
            adda_r[i] <= 64'd0;
            addb_r[i] <= 64'd0;
            en_r[i] <= 1'b0;
            sum_r[i] <= 65'd0;
        end
    end else begin
        adda_r[0] <= adda;
        addb_r[0] <= addb;
        en_r[0] <= i_en;
        sum_r[0] <= {1'b0, adda} + {1'b0, addb}; // First stage sum

        for (int i = 1; i < STAGES; i++) begin
            adda_r[i] <= adda_r[i-1];
            addb_r[i] <= addb_r[i-1];
            en_r[i] <= en_r[i-1];
            sum_r[i] <= sum_r[i-1]; // Propagate sum through stages
        end
    end
end

assign result = sum_r[STAGES-1];
assign o_en = en_r[STAGES-1];

endmodule