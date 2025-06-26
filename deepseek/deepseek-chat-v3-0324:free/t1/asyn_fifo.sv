module asyn_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
) (
    input wclk,
    input rclk,
    input wrstn,
    input rrstn,
    input winc,
    input rinc,
    input [WIDTH-1:0] wdata,
    output wfull,
    output rempty,
    output [WIDTH-1:0] rdata
);

localparam ADDR_WIDTH = $clog2(DEPTH);

reg [ADDR_WIDTH:0] waddr_bin, raddr_bin;
reg [ADDR_WIDTH:0] wptr, rptr;
reg [ADDR_WIDTH:0] wptr_syn, rptr_syn;
reg [ADDR_WIDTH:0] wptr_buff, rptr_buff;

wire [ADDR_WIDTH-1:0] waddr = waddr_bin[ADDR_WIDTH-1:0];
wire [ADDR_WIDTH-1:0] raddr = raddr_bin[ADDR_WIDTH-1:0];
wire wen = winc & ~wfull;
wire ren = rinc & ~rempty;

dual_port_RAM #(.WIDTH(WIDTH), .DEPTH(DEPTH)) ram (
    .wclk(wclk),
    .wenc(wen),
    .waddr(waddr),
    .wdata(wdata),
    .rclk(rclk),
    .renc(ren),
    .raddr(raddr),
    .rdata(rdata)
);

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 0;
        wptr <= 0;
        wptr_buff <= 0;
    end else begin
        if (wen) waddr_bin <= waddr_bin + 1;
        wptr <= (waddr_bin >> 1) ^ waddr_bin;
        wptr_buff <= wptr;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 0;
        rptr <= 0;
        rptr_buff <= 0;
    end else begin
        if (ren) raddr_bin <= raddr_bin + 1;
        rptr <= (raddr_bin >> 1) ^ raddr_bin;
        rptr_buff <= rptr;
    end
end

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_syn <= 0;
    end else begin
        rptr_syn <= rptr_buff;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_syn <= 0;
    end else begin
        wptr_syn <= wptr_buff;
    end
end

assign wfull = (wptr == {~rptr_syn[ADDR_WIDTH:ADDR_WIDTH-1], rptr_syn[ADDR_WIDTH-2:0]});
assign rempty = (rptr == wptr_syn);

endmodule

module dual_port_RAM #(
    parameter WIDTH = 8,
    parameter DEPTH = 16
) (
    input wclk,
    input wenc,
    input [$clog2(DEPTH)-1:0] waddr,
    input [WIDTH-1:0] wdata,
    input rclk,
    input renc,
    input [$clog2(DEPTH)-1:0] raddr,
    output reg [WIDTH-1:0] rdata
);

reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

always @(posedge wclk) begin
    if (wenc) RAM_MEM[waddr] <= wdata;
end

always @(posedge rclk) begin
    if (renc) rdata <= RAM_MEM[raddr];
end

endmodule