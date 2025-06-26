module RAM (
    clk,
    rst_n,
    write_en,
    write_addr,
    write_data,
    read_en,
    read_addr,
    read_data
);

parameter WIDTH = 6;
parameter DEPTH = 8;

input clk;
input rst_n;
input write_en;
input [2:0] write_addr;
input [WIDTH-1:0] write_data;
input read_en;
input [2:0] read_addr;
output reg [WIDTH-1:0] read_data;

reg [WIDTH-1:0] mem [DEPTH-1:0];

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        mem[0] <= 0;
        mem[1] <= 0;
        mem[2] <= 0;
        mem[3] <= 0;
        mem[4] <= 0;
        mem[5] <= 0;
        mem[6] <= 0;
        mem[7] <= 0;
    end
    else if (write_en) begin
        mem[write_addr] <= write_data;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_data <= 0;
    end
    else if (read_en) begin
        read_data <= mem[read_addr];
    end
    else begin
        read_data <= 0;
    end
end

endmodule