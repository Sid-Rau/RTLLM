module asyn_fifo #(parameter WIDTH = 8, parameter DEPTH = 16)(
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

    function [3:0] bin2gray;
        input [3:0] bin;
        begin
            bin2gray = (bin >> 1) ^ bin;
        end
    endfunction

    reg [3:0] waddr_bin, raddr_bin;
    reg [3:0] wptr, rptr;
    reg [3:0] wptr_buff, rptr_buff;
    wire [3:0] waddr, raddr;
    wire [3:0] wptr_syn, rptr_syn;
    wire wenc, renc;

    assign waddr = waddr_bin[2:0];
    assign raddr = raddr_bin[2:0];
    assign wenc = winc & ~wfull;
    assign renc = rinc & ~rempty;

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn) begin
            waddr_bin <= 4'b0;
            wptr <= 4'b0;
            wptr_buff <= 4'b0;
        end else if (wenc) begin
            waddr_bin <= waddr_bin + 1;
            wptr <= bin2gray(waddr_bin + 1);
            wptr_buff <= wptr;
        end
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn) begin
            raddr_bin <= 4'b0;
            rptr <= 4'b0;
            rptr_buff <= 4'b0;
        end else if (renc) begin
            raddr_bin <= raddr_bin + 1;
            rptr <= bin2gray(raddr_bin + 1);
            rptr_buff <= rptr;
        end
    end

    dual_port_RAM #(.DEPTH(DEPTH), .WIDTH(WIDTH)) ram (
        .wclk(wclk),
        .wenc(wenc),
        .waddr(waddr),
        .wdata(wdata),
        .rclk(rclk),
        .renc(renc),
        .raddr(raddr),
        .rdata(rdata)
    );

    always @(posedge wclk or negedge wrstn) begin
        if (!wrstn)
            rptr_buff <= 4'b0;
        else
            rptr_buff <= rptr_syn;
    end

    always @(posedge rclk or negedge rrstn) begin
        if (!rrstn)
            wptr_buff <= 4'b0;
        else
            wptr_buff <= wptr_syn;
    end

    assign wptr_syn = {rptr_buff[3], rptr_buff[3:0]};
    assign rptr_syn = {wptr_buff[3], wptr_buff[3:0]};

    assign wfull = (wptr[3:2] == ~rptr_syn[3:2]) && (wptr[1:0] == rptr_syn[1:0]);
    assign rempty = (rptr == wptr_syn);

endmodule

module dual_port_RAM #(parameter DEPTH = 16, parameter WIDTH = 8)(
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