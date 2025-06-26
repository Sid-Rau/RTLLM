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
reg [ADDR_WIDTH:0] wptr_syn0, wptr_syn1, wptr_syn2;
reg [ADDR_WIDTH:0] rptr_syn0, rptr_syn1, rptr_syn2;
wire [ADDR_WIDTH-1:0] waddr, raddr;
wire wen, ren;

dual_port_RAM #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) u_ram (
    .wclk(wclk),
    .wenc(wen),
    .waddr(waddr),
    .wdata(wdata),
    .rclk(rclk),
    .renc(ren),
    .raddr(raddr),
    .rdata(rdata)
);

assign wen = winc && !wfull;
assign ren = rinc && !rempty;
assign waddr = waddr_bin[ADDR_WIDTH-1:0];
assign raddr = raddr_bin[ADDR_WIDTH-1:0];
assign wfull = (wptr == {~rptr_syn2[ADDR_WIDTH:ADDR_WIDTH-1], rptr_syn2[ADDR_WIDTH-2:0]});
assign rempty = (rptr == wptr_syn2);

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 0;
        wptr <= 0;
    end else begin
        if (wen) begin
            waddr_bin <= waddr_bin + 1;
        end
        wptr <= (waddr_bin >> 1) ^ waddr_bin;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 0;
        rptr <= 0;
    end else begin
        if (ren) begin
            raddr_bin <= raddr_bin + 1;
        end
        rptr <= (raddr_bin >> 1) ^ raddr_bin;
    end
end

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_syn0 <= 0;
        rptr_syn1 <= 0;
        rptr_syn2 <= 0;
    end else begin
        rptr_syn0 <= rptr;
        rptr_syn1 <= rptr_syn0;
        rptr_syn2 <= rptr_syn1;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_syn0 <= 0;
        wptr_syn1 <= 0;
        wptr_syn2 <= 0;
    end else begin
        wptr_syn0 <= wptr;
        wptr_syn1 <= wptr_syn0;
        wptr_syn2 <= wptr_syn1;
    end
end

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
    if (wenc) begin
        RAM_MEM[waddr] <= wdata;
    end
end

always @(posedge rclk) begin
    if (renc) begin
        rdata <= RAM_MEM[raddr];
    end
end

endmodule