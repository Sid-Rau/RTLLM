module asyn_fifo #(parameter WIDTH = 8, parameter DEPTH = 16) (
    input wire wclk,
    input wire rclk,
    input wire wrstn,
    input wire rrstn,
    input wire winc,
    input wire rinc,
    input wire [WIDTH-1:0] wdata,
    output reg wfull,
    output reg rempty,
    output reg [WIDTH-1:0] rdata
);
    
    reg [$clog2(DEPTH)-1:0] waddr_bin, raddr_bin;
    reg [$clog2(DEPTH)-1:0] wptr, rptr;
    reg [$clog2(DEPTH)-1:0] wptr_buff, rptr_buff;
    wire [$clog2(DEPTH)-1:0] waddr, raddr;
    wire wenc, renc;
    
    dual_port_RAM #(.WIDTH(WIDTH), .DEPTH(DEPTH)) ram (
        .wclk(wclk),
        .wenc(wenc),
        .waddr(waddr),
        .wdata(wdata),
        .rclk(rclk),
        .renc(renc),
        .raddr(raddr),
        .rdata(rdata)
    );

    assign wenc = winc && !wfull;
    assign renc = rinc && !rempty;
    
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= 0;
        end else if (winc && !wfull) begin
            waddr_bin <= waddr_bin + 1;
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= 0;
        end else if (rinc && !rempty) begin
            raddr_bin <= raddr_bin + 1;
        end
    end

    always @(posedge wclk) begin
        wptr <= (waddr_bin ^ (waddr_bin >> 1));
        wptr_buff <= wptr;
    end

    always @(posedge rclk) begin
        rptr <= (raddr_bin ^ (raddr_bin >> 1));
        rptr_buff <= rptr;
    end

    always @* begin
        wfull = (wptr[3] ^ rptr_buff[3]) && (wptr[2:0] == rptr_buff[2:0]);
        rempty = (wptr == rptr_buff);
    end

    assign waddr = waddr_bin[$clog2(DEPTH)-1:0];
    assign raddr = raddr_bin[$clog2(DEPTH)-1:0];
    
endmodule

module dual_port_RAM #(parameter WIDTH = 8, parameter DEPTH = 16) (
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