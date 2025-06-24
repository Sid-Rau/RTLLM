module asyn_fifo #(parameter WIDTH = 8, parameter DEPTH = 16) (
    input wclk,
    input rclk,
    input wrstn,
    input rrstn,
    input winc,
    input rinc,
    input [WIDTH-1:0] wdata,
    output reg wfull,
    output reg rempty,
    output reg [WIDTH-1:0] rdata
);

    reg [$clog2(DEPTH):0] wptr, rptr, wptr_gray, rptr_gray;
    reg [$clog2(DEPTH):0] wptr_gray_sync1, wptr_gray_sync2;
    reg [$clog2(DEPTH):0] rptr_gray_sync1, rptr_gray_sync2;
    reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

    wire [$clog2(DEPTH)-1:0] waddr = wptr[$clog2(DEPTH)-1:0];
    wire [$clog2(DEPTH)-1:0] raddr = rptr[$clog2(DEPTH)-1:0];

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            wptr <= 0;
            wptr_gray <= 0;
        end else if (winc && !wfull) begin
            wptr <= wptr + 1;
            wptr_gray <= (wptr >> 1) ^ wptr;
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            rptr <= 0;
            rptr_gray <= 0;
        end else if (rinc && !rempty) begin
            rptr <= rptr + 1;
            rptr_gray <= (rptr >> 1) ^ rptr;
        end
    end

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            {wptr_gray_sync2, wptr_gray_sync1} <= 0;
        end else begin
            {wptr_gray_sync2, wptr_gray_sync1} <= {wptr_gray_sync1, rptr_gray};
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            {rptr_gray_sync2, rptr_gray_sync1} <= 0;
        end else begin
            {rptr_gray_sync2, rptr_gray_sync1} <= {rptr_gray_sync1, wptr_gray};
        end
    end

    always @(posedge wclk) begin
        if (winc && !wfull) begin
            RAM_MEM[waddr] <= wdata;
        end
    end

    always @(posedge rclk) begin
        if (rinc && !rempty) begin
            rdata <= RAM_MEM[raddr];
        end
    end

    always @(*) begin
        wfull = (wptr_gray == {~rptr_gray_sync2[$clog2(DEPTH):$clog2(DEPTH)-1], rptr_gray_sync2[$clog2(DEPTH)-2:0]});
        rempty = (rptr_gray == wptr_gray_sync2);
    end

endmodule