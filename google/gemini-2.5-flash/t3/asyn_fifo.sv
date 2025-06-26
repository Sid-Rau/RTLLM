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

wire [ADDR_WIDTH-1:0] waddr;
wire [ADDR_WIDTH-1:0] raddr;

reg wen;
reg ren;

wire [PTR_WIDTH-1:0] wptr_gray;
wire [PTR_WIDTH-1:0] rptr_gray;

reg [PTR_WIDTH-1:0] wptr_rclk_sync1;
reg [PTR_WIDTH-1:0] wptr_rclk_sync2;

reg [PTR_WIDTH-1:0] rptr_wclk_sync1;
reg [PTR_WIDTH-1:0] rptr_wclk_sync2;

wire [PTR_WIDTH-1:0] wptr_rclk_syn;
wire [PTR_WIDTH-1:0] rptr_wclk_syn;

// Dual-port RAM
reg [WIDTH-1:0] RAM_MEM [DEPTH-1:0];

always @(posedge wclk) begin
    if (wen) begin
        RAM_MEM[waddr] <= wdata;
    end
end

always @(posedge rclk) begin
    if (ren) begin
        rdata <= RAM_MEM[raddr];
    end
end

// Write Controller
reg [PTR_WIDTH-1:0] wptr_bin;

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        wptr_bin <= '0;
    end else begin
        if (winc && !wfull) begin
            wptr_bin <= wptr_bin + 1;
        end
    end
end

assign wptr_gray = (wptr_bin >> 1) ^ wptr_bin;
assign waddr = wptr_bin[ADDR_WIDTH-1:0];

assign wen = winc && !wfull;

// Read Controller
reg [PTR_WIDTH-1:0] rptr_bin;

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        rptr_bin <= '0;
    end else begin
        if (rinc && !rempty) begin
            rptr_bin <= rptr_bin + 1;
        end
    end
end

assign rptr_gray = (rptr_bin >> 1) ^ rptr_bin;
assign raddr = rptr_bin[ADDR_WIDTH-1:0];

assign ren = rinc && !rempty;

// Read Pointer Synchronizer (to wclk domain)
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_wclk_sync1 <= '0;
        rptr_wclk_sync2 <= '0;
    end else begin
        rptr_wclk_sync1 <= rptr_gray;
        rptr_wclk_sync2 <= rptr_wclk_sync1;
    end
end
assign rptr_wclk_syn = rptr_wclk_sync2;

// Write Pointer Synchronizer (to rclk domain)
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_rclk_sync1 <= '0;
        wptr_rclk_sync2 <= '0;
    end else begin
        wptr_rclk_sync1 <= wptr_gray;
        wptr_rclk_sync2 <= wptr_rclk_sync1;
    end
end
assign wptr_rclk_syn = wptr_rclk_sync2;

// Full and Empty Logic
assign rempty = (wptr_wclk_syn == rptr_gray);
assign wfull = (wptr_gray[PTR_WIDTH-1] != rptr_wclk_syn[PTR_WIDTH-1]) &&
               (wptr_gray[PTR_WIDTH-2] != rptr_wclk_syn[PTR_WIDTH-2]) &&
               (wptr_gray[PTR_WIDTH-3:0] == rptr_wclk_syn[PTR_WIDTH-3:0]);

endmodule