module asyn_fifo #(parameter WIDTH = 8, parameter DEPTH = 16) (
    input wire wclk,
    input wire rclk,
    input wire wrstn,
    input wire rrstn,
    input wire winc,
    input wire rinc,
    input wire [WIDTH-1:0] wdata,
    output wire wfull,
    output wire rempty,
    output wire [WIDTH-1:0] rdata
);

    // Internal signals
    reg [$clog2(DEPTH):0] wptr_bin, rptr_bin;
    reg [$clog2(DEPTH):0] wptr_gray, rptr_gray;
    reg [$clog2(DEPTH):0] wptr_gray_sync1, wptr_gray_sync2;
    reg [$clog2(DEPTH):0] rptr_gray_sync1, rptr_gray_sync2;
    wire [$clog2(DEPTH)-1:0] waddr, raddr;
    wire wenc, renc;

    // Dual-port RAM instantiation
    dual_port_RAM #(.DEPTH(DEPTH), .WIDTH(WIDTH)) ram_inst (
        .wclk(wclk),
        .wenc(wenc),
        .waddr(waddr),
        .wdata(wdata),
        .rclk(rclk),
        .renc(renc),
        .raddr(raddr),
        .rdata(rdata)
    );

    // Write pointer logic
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn)
            wptr_bin <= 0;
        else if (winc && !wfull)
            wptr_bin <= wptr_bin + 1;
    end

    // Write pointer binary to Gray code conversion
    always @* begin
        wptr_gray = (wptr_bin >> 1) ^ wptr_bin;
    end

    // Read pointer logic
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn)
            rptr_bin <= 0;
        else if (rinc && !rempty)
            rptr_bin <= rptr_bin + 1;
    end

    // Read pointer binary to Gray code conversion
    always @* begin
        rptr_gray = (rptr_bin >> 1) ^ rptr_bin;
    end

    // Synchronize write pointer to read clock domain
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            wptr_gray_sync1 <= 0;
            wptr_gray_sync2 <= 0;
        end else begin
            wptr_gray_sync1 <= wptr_gray;
            wptr_gray_sync2 <= wptr_gray_sync1;
        end
    end

    // Synchronize read pointer to write clock domain
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            rptr_gray_sync1 <= 0;
            rptr_gray_sync2 <= 0;
        end else begin
            rptr_gray_sync1 <= rptr_gray;
            rptr_gray_sync2 <= rptr_gray_sync1;
        end
    end

    // Full and empty flag logic
    assign wfull = (wptr_gray == {~rptr_gray_sync2[$clog2(DEPTH):$clog2(DEPTH)-1], rptr_gray_sync2[$clog2(DEPTH)-2:0]});
    assign rempty = (rptr_gray == wptr_gray_sync2);

    // Address and enable logic
    assign waddr = wptr_bin[$clog2(DEPTH)-1:0];
    assign raddr = rptr_bin[$clog2(DEPTH)-1:0];
    assign wenc = winc && !wfull;
    assign renc = rinc && !rempty;

endmodule

module dual_port_RAM #(parameter DEPTH = 16, parameter WIDTH = 8) (
    input wire wclk,
    input wire wenc,
    input wire [$clog2(DEPTH)-1:0] waddr,
    input wire [WIDTH-1:0] wdata,
    input wire rclk,
    input wire renc,
    input wire [$clog2(DEPTH)-1:0] raddr,
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