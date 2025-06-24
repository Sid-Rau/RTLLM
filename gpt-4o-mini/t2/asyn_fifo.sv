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
    reg [WIDTH-1:0] ram [0:DEPTH-1];
    reg [$clog2(DEPTH)-1:0] waddr_bin, raddr_bin;
    reg [$clog2(DEPTH)-1:0] wptr, rptr, wptr_buff, rptr_buff;

    wire [$clog2(DEPTH)-1:0] waddr_gray, raddr_gray;
    wire [$clog2(DEPTH)-1:0] waddr, raddr;

    assign waddr_gray = waddr_bin ^ (waddr_bin >> 1);
    assign raddr_gray = raddr_bin ^ (raddr_bin >> 1);
    
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= 0;
        end else if (winc && !wfull) begin
            ram[waddr_bin] <= wdata;
            waddr_bin <= waddr_bin + 1;
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= 0;
        end else if (rinc && !rempty) begin
            rdata <= ram[raddr_bin];
            raddr_bin <= raddr_bin + 1;
        end
    end

    always @(posedge wclk) begin
        wptr_buff <= wptr;
        wptr <= waddr_gray;
    end

    always @(posedge rclk) begin
        rptr_buff <= rptr;
        rptr <= raddr_gray;
    end

    always @* begin
        wfull = (wptr[3] ^ rptr[3]) && (wptr[2:0] == rptr[2:0]);
        rempty = (wptr == rptr);
    end
endmodule