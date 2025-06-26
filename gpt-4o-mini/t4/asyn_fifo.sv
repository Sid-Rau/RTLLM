module asyn_fifo #(parameter DEPTH = 16, parameter WIDTH = 8) (
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
    reg [$clog2(DEPTH)-1:0] waddr_bin, raddr_bin;
    reg [$clog2(DEPTH)-1:0] wptr, rptr;
    reg [$clog2(DEPTH)-1:0] wptr_buff, rptr_buff;
    reg [WIDTH-1:0] ram [0:DEPTH-1];

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= 0;
            wptr <= 0;
        end else if (winc && !wfull) begin
            ram[waddr_bin] <= wdata;
            waddr_bin <= waddr_bin + 1;
            wptr <= wptr + 1;
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= 0;
            rptr <= 0;
        end else if (rinc && !rempty) begin
            rdata <= ram[raddr_bin];
            raddr_bin <= raddr_bin + 1;
            rptr <= rptr + 1;
        end
    end

    always @(posedge wclk) begin
        wptr_buff <= wptr;
    end

    always @(posedge rclk) begin
        rptr_buff <= rptr;
    end

    always @(*) begin
        wfull = (wptr[3] ^ rptr_buff[3]) && (wptr[2:0] == rptr_buff[2:0]);
        rempty = (wptr == rptr);
    end

endmodule