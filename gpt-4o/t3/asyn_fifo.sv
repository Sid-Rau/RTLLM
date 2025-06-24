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

    reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];
    reg [$clog2(DEPTH):0] wptr, rptr, wptr_gray, rptr_gray;
    reg [$clog2(DEPTH):0] wptr_syn, rptr_syn;
    reg [$clog2(DEPTH)-1:0] waddr, raddr;

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            wptr <= 0;
            wptr_gray <= 0;
        end else if (winc && !wfull) begin
            wptr <= wptr + 1;
            wptr_gray <= (wptr + 1) ^ ((wptr + 1) >> 1);
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            rptr <= 0;
            rptr_gray <= 0;
        end else if (rinc && !rempty) begin
            rptr <= rptr + 1;
            rptr_gray <= (rptr + 1) ^ ((rptr + 1) >> 1);
        end
    end

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            rptr_syn <= 0;
        end else begin
            rptr_syn <= rptr_gray;
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            wptr_syn <= 0;
        end else begin
            wptr_syn <= wptr_gray;
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

    always @* begin
        waddr = wptr[$clog2(DEPTH)-1:0];
        raddr = rptr[$clog2(DEPTH)-1:0];
        wfull = (wptr_gray == {~rptr_syn[$clog2(DEPTH):$clog2(DEPTH)-1], rptr_syn[$clog2(DEPTH)-2:0]});
        rempty = (rptr_gray == wptr_syn);
    end

endmodule