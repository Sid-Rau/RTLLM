module dual_port_RAM #(parameter DEPTH = 16, parameter WIDTH = 8)
(
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
        if (wenc)
            RAM_MEM[waddr] <= wdata;
    end

    always @(posedge rclk) begin
        if (renc)
            rdata <= RAM_MEM[raddr];
    end
endmodule

module asyn_fifo #(parameter WIDTH = 8, parameter DEPTH = 16)
(
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
    reg [$clog2(DEPTH):0] wptr_bin, rptr_bin;
    reg [$clog2(DEPTH):0] wptr_gray, rptr_gray;
    reg [$clog2(DEPTH):0] wptr_gray_sync1, wptr_gray_sync2;
    reg [$clog2(DEPTH):0] rptr_gray_sync1, rptr_gray_sync2;

    wire [$clog2(DEPTH)-1:0] waddr = wptr_bin[$clog2(DEPTH)-1:0];
    wire [$clog2(DEPTH)-1:0] raddr = rptr_bin[$clog2(DEPTH)-1:0];

    dual_port_RAM #(DEPTH, WIDTH) ram_inst (
        .wclk(wclk),
        .wenc(winc & ~wfull),
        .waddr(waddr),
        .wdata(wdata),
        .rclk(rclk),
        .renc(rinc & ~rempty),
        .raddr(raddr),
        .rdata(rdata)
    );

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            wptr_bin <= 0;
            wptr_gray <= 0;
        end else if (winc & ~wfull) begin
            wptr_bin <= wptr_bin + 1;
            wptr_gray <= (wptr_bin >> 1) ^ wptr_bin;
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            rptr_bin <= 0;
            rptr_gray <= 0;
        end else if (rinc & ~rempty) begin
            rptr_bin <= rptr_bin + 1;
            rptr_gray <= (rptr_bin >> 1) ^ rptr_bin;
        end
    end

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            rptr_gray_sync1 <= 0;
            rptr_gray_sync2 <= 0;
        end else begin
            rptr_gray_sync1 <= rptr_gray;
            rptr_gray_sync2 <= rptr_gray_sync1;
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            wptr_gray_sync1 <= 0;
            wptr_gray_sync2 <= 0;
        end else begin
            wptr_gray_sync1 <= wptr_gray;
            wptr_gray_sync2 <= wptr_gray_sync1;
        end
    end

    assign wfull = (wptr_gray == {~rptr_gray_sync2[$clog2(DEPTH):$clog2(DEPTH)-1], rptr_gray_sync2[$clog2(DEPTH)-2:0]});
    assign rempty = (rptr_gray == wptr_gray_sync2);

endmodule