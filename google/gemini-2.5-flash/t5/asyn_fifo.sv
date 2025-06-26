module dual_port_RAM #(
    parameter DEPTH = 16,
    parameter WIDTH = 8
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

reg [WIDTH-1:0] RAM_MEM [DEPTH-1:0];

always @(posedge wclk) begin
    if (wenc) begin
        RAM_MEM[waddr] <= wdata;
    end
end

always @(posedge rclk) begin
    if (renc) begin
        rdata <= RAM_MEM[raddr];
    end else begin
        rdata <= 'bz; 
    end
end

endmodule

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

reg [ADDR_WIDTH-1:0] waddr_bin;
reg [ADDR_WIDTH-1:0] raddr_bin;

reg [PTR_WIDTH-1:0] wptr;
reg [PTR_WIDTH-1:0] rptr;

reg [PTR_WIDTH-1:0] wptr_buff1;
reg [PTR_WIDTH-1:0] wptr_buff2;
reg [PTR_WIDTH-1:0] rptr_buff1;
reg [PTR_WIDTH-1:0] rptr_buff2;

wire [PTR_WIDTH-1:0] wptr_syn;
wire [PTR_WIDTH-1:0] rptr_syn;

wire wen;
wire ren;

function [PTR_WIDTH-1:0] bin_to_gray;
    input [PTR_WIDTH-1:0] bin;
    begin
        bin_to_gray = (bin >> 1) ^ bin;
    end
endfunction

function [ADDR_WIDTH-1:0] gray_to_bin;
    input [PTR_WIDTH-1:0] gray;
    reg [PTR_WIDTH-1:0] bin;
    integer i;
    begin
        bin[PTR_WIDTH-1] = gray[PTR_WIDTH-1];
        for (i = PTR_WIDTH-2; i >= 0; i = i - 1) begin
            bin[i] = bin[i+1] ^ gray[i];
        end
        gray_to_bin = bin[ADDR_WIDTH-1:0];
    end
endfunction

// Write Pointer Logic
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        waddr_bin <= 'd0;
        wptr <= 'd0;
    end else begin
        if (winc && !wfull) begin
            waddr_bin <= waddr_bin + 1;
            wptr <= bin_to_gray(waddr_bin + 1);
        end
    end
end

// Read Pointer Synchronization (wclk domain)
always @(posedge wclk or negedge wrstn) begin
    if (!wrstn) begin
        rptr_buff1 <= 'd0;
        rptr_buff2 <= 'd0;
    end else begin
        rptr_buff1 <= rptr;
        rptr_buff2 <= rptr_buff1;
    end
end
assign rptr_syn = rptr_buff2;

// Full logic
assign wfull = (wptr[PTR_WIDTH-1] != rptr_syn[PTR_WIDTH-1]) &&
               (wptr[PTR_WIDTH-2] != rptr_syn[PTR_WIDTH-2]) &&
               (wptr[PTR_WIDTH-3:0] == rptr_syn[PTR_WIDTH-3:0]);

assign wen = winc && !wfull;

// Read Pointer Logic
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        raddr_bin <= 'd0;
        rptr <= 'd0;
    end else begin
        if (rinc && !rempty) begin
            raddr_bin <= raddr_bin + 1;
            rptr <= bin_to_gray(raddr_bin + 1);
        end
    end
end

// Write Pointer Synchronization (rclk domain)
always @(posedge rclk or negedge rrstn) begin
    if (!rrstn) begin
        wptr_buff1 <= 'd0;
        wptr_buff2 <= 'd0;
    end else begin
        wptr_buff1 <= wptr;
        wptr_buff2 <= wptr_buff1;
    end
end
assign wptr_syn = wptr_buff2;

// Empty logic
assign rempty = (rptr == wptr_syn);

assign ren = rinc && !rempty;

dual_port_RAM #(
    .DEPTH(DEPTH),
    .WIDTH(WIDTH)
) u_dual_port_RAM (
    .wclk(wclk),
    .wenc(wen),
    .waddr(gray_to_bin(wptr)),
    .wdata(wdata),
    .rclk(rclk),
    .renc(ren),
    .raddr(gray_to_bin(rptr)),
    .rdata(rdata)
);

endmodule