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
    
    reg [$clog2(DEPTH)-1:0] waddr_bin, raddr_bin;
    reg [$clog2(DEPTH)-1:0] wptr, rptr;
    reg [$clog2(DEPTH)-1:0] wptr_buff, rptr_buff;
    
    wire [WIDTH-1:0] ram_rdata;
    wire ram_wen, ram_ren;
    
    dual_port_RAM #(.WIDTH(WIDTH), .DEPTH(DEPTH)) ram (
        .wclk(wclk),
        .wenc(ram_wen),
        .waddr(waddr_bin),
        .wdata(wdata),
        .rclk(rclk),
        .renc(ram_ren),
        .raddr(raddr_bin),
        .rdata(ram_rdata)
    );
    
    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= 0;
            wptr <= 0;
        end else if (winc && !wfull) begin
            waddr_bin <= waddr_bin + 1;
            wptr <= wptr + 1;
        end
    end
    
    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= 0;
            rptr <= 0;
        end else if (rinc && !rempty) begin
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
    
    assign ram_wen = winc && !wfull;
    assign ram_ren = rinc && !rempty;
    
    always @(*) begin
        rdata = ram_rdata;
    end

endmodule

module dual_port_RAM #(parameter WIDTH = 8, parameter DEPTH = 16) (
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