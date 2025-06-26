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

reg [ADDR_WIDTH:0] waddr_bin;
reg [ADDR_WIDTH:0] raddr_bin;
reg [ADDR_WIDTH:0] wptr, wptr_buff;
reg [ADDR_WIDTH:0] rptr, rptr_buff;
reg [ADDR_WIDTH:0] wptr_syn0, wptr_syn1;
reg [ADDR_WIDTH:0] rptr_syn0, rptr_syn1;
wire [ADDR_WIDTH:0] wgray_next, rgray_next;
wire [ADDR_WIDTH:0] wbin_next, rbin_next;
wire wen, ren;
wire [ADDR_WIDTH-1:0] waddr, raddr;

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

assign waddr = waddr_bin[ADDR_WIDTH-1:0];
assign raddr = raddr_bin[ADDR_WIDTH-1:0];
assign wen = winc && !wfull;
assign ren = rinc && !rempty;

assign wbin_next = waddr_bin + (wen & !wfull);
assign wgray_next = wbin_next ^ (wbin_next >> 1);

assign rbin_next = raddr_bin + (ren & !rempty);
assign rgray_next = rbin_next ^ (rbin_next >> 1);

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 0;
        wptr <= 0;
        wptr_buff <= 0;
    end else begin
        waddr_bin <= wbin_next;
        wptr <= wgray_next;
        wptr_buff <= wptr;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 0;
        rptr <= 0;
        rptr_buff <= 0;
    end else begin
        raddr_bin <= rbin_next;
        rptr <= rgray_next;
        rptr_buff <= rptr;
    end
end

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_syn0 <= 0;
        rptr_syn1 <= 0;
    end else begin
        rptr_syn0 <= rptr;
        rptr_syn1 <= rptr_syn0;
    end
end

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_syn0 <= 0;
        wptr_syn1 <= 0;
    end else begin
        wptr_syn0 <= wptr;
        wptr_syn1 <= wptr_syn0;
    end
end

assign rempty = (rptr == wptr_syn1);
assign wfull = (wptr == {~rptr_syn1[ADDR_WIDTH:ADDR_WIDTH-1], rptr_syn1[ADDR_WIDTH-2:0]});

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