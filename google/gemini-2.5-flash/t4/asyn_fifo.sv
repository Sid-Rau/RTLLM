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
localparam PTR_WIDTH = ADDR_WIDTH + 1;

wire [WIDTH-1:0] ram_rdata;
wire [ADDR_WIDTH-1:0] ram_waddr;
wire [ADDR_WIDTH-1:0] ram_raddr;
wire ram_wenc;
wire ram_renc;

reg [ADDR_WIDTH-1:0] waddr_bin;
reg [ADDR_WIDTH-1:0] raddr_bin;

reg [PTR_WIDTH-1:0] wptr_gray;
reg [PTR_WIDTH-1:0] rptr_gray;

reg [PTR_WIDTH-1:0] wptr_sync_rclk_stage1;
reg [PTR_WIDTH-1:0] wptr_sync_rclk;
reg [PTR_WIDTH-1:0] rptr_sync_wclk_stage1;
reg [PTR_WIDTH-1:0] rptr_sync_wclk;

// Dual-port RAM instantiation
dual_port_RAM #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) ram_inst (
    .wclk(wclk),
    .wenc(ram_wenc),
    .waddr(ram_waddr),
    .wdata(wdata),
    .rclk(rclk),
    .renc(ram_renc),
    .raddr(ram_raddr),
    .rdata(ram_rdata)
);

assign rdata = ram_rdata;

// Write controller
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= '0;
        wptr_gray <= '0;
    end else begin
        if (winc && !wfull) begin
            waddr_bin <= waddr_bin + 1;
        end
        wptr_gray <= (waddr_bin + (winc && !wfull)) ^ ((waddr_bin + (winc && !wfull)) >> 1);
    end
end

assign ram_waddr = waddr_bin;
assign ram_wenc = winc && !wfull;

// Read controller
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= '0;
        rptr_gray <= '0;
    end else begin
        if (rinc && !rempty) begin
            raddr_bin <= raddr_bin + 1;
        end
        rptr_gray <= (raddr_bin + (rinc && !rempty)) ^ ((raddr_bin + (rinc && !rempty)) >> 1);
    end
end

assign ram_raddr = raddr_bin;
assign ram_renc = rinc && !rempty;

// Synchronize read pointer to write clock domain
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_sync_wclk_stage1 <= '0;
        rptr_sync_wclk <= '0;
    end else begin
        rptr_sync_wclk_stage1 <= rptr_gray;
        rptr_sync_wclk <= rptr_sync_wclk_stage1;
    end
end

// Synchronize write pointer to read clock domain
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_sync_rclk_stage1 <= '0;
        wptr_sync_rclk <= '0;
    end else begin
        wptr_sync_rclk_stage1 <= wptr_gray;
        wptr_sync_rclk <= wptr_sync_rclk_stage1;
    end
end

// Full and Empty logic
assign wfull = (wptr_gray[PTR_WIDTH-1] != rptr_sync_wclk[PTR_WIDTH-1]) &&
               (wptr_gray[PTR_WIDTH-2] != rptr_sync_wclk[PTR_WIDTH-2]) &&
               (wptr_gray[PTR_WIDTH-3:0] == rptr_sync_wclk[PTR_WIDTH-3:0]);

assign rempty = (rptr_gray == wptr_sync_rclk);

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
    end else begin
        rdata <= '0; // Or keep previous value, depending on desired behavior when renc is low
    end
end

endmodule