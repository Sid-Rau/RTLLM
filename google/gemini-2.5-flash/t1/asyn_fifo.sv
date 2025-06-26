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

wire [ADDR_WIDTH-1:0] waddr;
wire [ADDR_WIDTH-1:0] raddr;
wire wen;
wire ren;

reg [ADDR_WIDTH:0] wptr_bin;
reg [ADDR_WIDTH:0] rptr_bin;

wire [ADDR_WIDTH:0] wptr_gray;
wire [ADDR_WIDTH:0] rptr_gray;

reg [ADDR_WIDTH:0] rptr_sync1;
reg [ADDR_WIDTH:0] rptr_sync2;

reg [ADDR_WIDTH:0] wptr_sync1;
reg [ADDR_WIDTH:0] wptr_sync2;

// Dual-port RAM instantiation
dual_port_RAM #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) ram_inst (
    .wclk(wclk),
    .wenc(wen),
    .waddr(waddr),
    .wdata(wdata),
    .rclk(rclk),
    .renc(ren),
    .raddr(raddr),
    .rdata(rdata)
);

// Write Pointer Logic
assign wen = winc && !wfull;
assign waddr = wptr_bin[ADDR_WIDTH-1:0];

always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        wptr_bin <= {(ADDR_WIDTH+1){1'b0}};
    end else if (wen) begin
        wptr_bin <= wptr_bin + 1;
    end
end

// Read Pointer Logic
assign ren = rinc && !rempty;
assign raddr = rptr_bin[ADDR_WIDTH-1:0];

always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        rptr_bin <= {(ADDR_WIDTH+1){1'b0}};
    end else if (ren) begin
        rptr_bin <= rptr_bin + 1;
    end
end

// Binary to Gray Code Conversion
assign wptr_gray = (wptr_bin >> 1) ^ wptr_bin;
assign rptr_gray = (rptr_bin >> 1) ^ rptr_bin;

// Read Pointer Synchronization (to write clock domain)
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_sync1 <= {(ADDR_WIDTH+1){1'b0}};
        rptr_sync2 <= {(ADDR_WIDTH+1){1'b0}};
    end else begin
        rptr_sync1 <= rptr_gray;
        rptr_sync2 <= rptr_sync1;
    end
end

// Write Pointer Synchronization (to read clock domain)
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_sync1 <= {(ADDR_WIDTH+1){1'b0}};
        wptr_sync2 <= {(ADDR_WIDTH+1){1'b0}};
    end else begin
        wptr_sync1 <= wptr_gray;
        wptr_sync2 <= wptr_sync1;
    end
end

// Full and Empty Logic
assign wfull = (wptr_gray[ADDR_WIDTH] != rptr_sync2[ADDR_WIDTH]) &&
               (wptr_gray[ADDR_WIDTH-1] != rptr_sync2[ADDR_WIDTH-1]) &&
               (wptr_gray[ADDR_WIDTH-2:0] == rptr_sync2[ADDR_WIDTH-2:0]);

assign rempty = (rptr_gray == wptr_sync2);

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
        rdata <= {WIDTH{1'b0}}; // Output 0 if not enabled
    end
end

endmodule