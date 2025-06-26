module RAM #(
    parameter WIDTH = 6,
    parameter DEPTH = 8
) (
    input wire clk,
    input wire rst_n,
    input wire write_en,
    input wire [$clog2(DEPTH)-1:0] write_addr,
    input wire [WIDTH-1:0] write_data,
    input wire read_en,
    input wire [$clog2(DEPTH)-1:0] read_addr,
    output reg [WIDTH-1:0] read_data
);

reg [WIDTH-1:0] mem [DEPTH-1:0];

integer i;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            mem[i] <= {WIDTH{1'b0}};
        end
    end else begin
        if (write_en) begin
            mem[write_addr] <= write_data;
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_data <= {WIDTH{1'b0}};
    end else begin
        if (read_en) begin
            read_data <= mem[read_addr];
        end else begin
            read_data <= {WIDTH{1'b0}};
        end
    end
end

endmodule