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

reg [ADDR_WIDTH-1:0] waddr;
reg [ADDR_WIDTH-1:0] raddr;

reg [PTR_WIDTH-1:0] wptr_bin;
reg [PTR_WIDTH-1:0] rptr_bin;

reg [PTR_WIDTH-1:0] wptr;
reg [PTR_WIDTH-1:0] rptr;

reg [PTR_WIDTH-1:0] wptr_syn_rclk_reg1;
reg [PTR_WIDTH-1:0] wptr_syn_rclk_reg2;
wire [PTR_WIDTH-1:0] wptr_syn;

reg [PTR_WIDTH-1:0] rptr_syn_wclk_reg1;
reg [PTR_WIDTH-1:0] rptr_syn_wclk_reg2;
wire [PTR_WIDTH-1:0] rptr_syn;

wire wen;
wire ren;

wire [WIDTH-1:0] ram_rdata;

function [PTR_WIDTH-1:0] bin_to_gray;
    input [PTR_WIDTH-1:0] bin;
    begin
        bin_to_gray = (bin >> 1) ^ bin;
    end
endfunction

function [ADDR_WIDTH-1:0] gray_to_bin_addr;
    input [PTR_WIDTH-1:0] gray;
    begin
        gray_to_bin_addr = (gray[ADDR_WIDTH-1:0] >> 1) ^ gray[ADDR_WIDTH-1:0];
        gray_to_bin_addr = (gray_to_bin_addr >> 2) ^ gray_to_bin_addr;
        gray_to_bin_addr = (gray_to_bin_addr >> 4) ^ gray_to_bin_addr;
        gray_to_bin_addr = (gray_to_bin_addr >> 8) ^ gray_to_bin_addr;
    end
endfunction

// Write Pointer Logic
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        wptr_bin <= 0;
        wptr <= 0;
    end else begin
        if (winc && !wfull) begin
            wptr_bin <= wptr_bin + 1;
            wptr <= bin_to_gray(wptr_bin + 1);
        end
    end
end

assign waddr = gray_to_bin_addr(wptr);

// Read Pointer Logic
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        rptr_bin <= 0;
        rptr <= 0;
    end else begin
        if (rinc && !rempty) begin
            rptr_bin <= rptr_bin + 1;
            rptr <= bin_to_gray(rptr_bin + 1);
        end
    end
end

assign raddr = gray_to_bin_addr(rptr);

// Write Pointer Synchronization to RCLK
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_syn_rclk_reg1 <= 0;
        wptr_syn_rclk_reg2 <= 0;
    end else begin
        wptr_syn_rclk_reg1 <= wptr;
        wptr_syn_rclk_reg2 <= wptr_syn_rclk_reg1;
    end
end
assign wptr_syn = wptr_syn_rclk_reg2;

// Read Pointer Synchronization to WCLK
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_syn_wclk_reg1 <= 0;
        rptr_syn_wclk_reg2 <= 0;
    end else begin
        rptr_syn_wclk_reg1 <= rptr;
        rptr_syn_wclk_reg2 <= rptr_syn_wclk_reg1;
    end
end
assign rptr_syn = rptr_syn_wclk_reg2;

// Full and Empty Logic
assign wfull = (wptr_syn[PTR_WIDTH-1] != rptr[PTR_WIDTH-1]) &&
               (wptr_syn[PTR_WIDTH-2] != rptr[PTR_WIDTH-2]) &&
               (wptr_syn[PTR_WIDTH-3:0] == rptr[PTR_WIDTH-3:0]);

assign rempty = (wptr == rptr_syn);

assign wen = winc && !wfull;
assign ren = rinc && !rempty;

dual_port_RAM #(
    .WIDTH(WIDTH),
    .DEPTH(DEPTH)
) i_dual_port_RAM (
    .wclk(wclk),
    .wenc(wen),
    .waddr(waddr),
    .wdata(wdata),
    .rclk(rclk),
    .renc(ren),
    .raddr(raddr),
    .rdata(ram_rdata)
);

assign rdata = ram_rdata;

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