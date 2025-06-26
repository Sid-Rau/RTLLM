module verified_adder_64bit
(
    input clk,
    input rst_n,
    input i_en,
    input [63:0] adda,
    input [63:0] addb,
    output [64:0] result,
    output reg o_en
);

reg stage1;
reg stage2;
reg stage3;

wire [15:0] a1;
wire [15:0] b1;
wire [15:0] a2;
wire [15:0] b2;
wire [15:0] a3;
wire [15:0] b3;
wire [15:0] a4;
wire [15:0] b4;

reg [15:0] a2_ff1;
reg [15:0] b2_ff1;

reg [15:0] a3_ff1;
reg [15:0] b3_ff1;
reg [15:0] a3_ff2;
reg [15:0] b3_ff2;

reg [15:0] a4_ff1;
reg [15:0] b4_ff1;
reg [15:0] a4_ff2;
reg [15:0] b4_ff2;
reg [15:0] a4_ff3;
reg [15:0] b4_ff3;

reg c1;
reg c2;
reg c3;
reg c4;

reg [15:0] s1;
reg [15:0] s2;
reg [15:0] s3;
reg [15:0] s4;

reg [15:0] s1_ff1;
reg [15:0] s1_ff2;
reg [15:0] s1_ff3;

reg [15:0] s2_ff1;
reg [15:0] s2_ff2;

reg [15:0] s3_ff1;

assign a1 = adda[15:0];
assign b1 = addb[15:0];
assign a2 = adda[31:16];
assign b2 = addb[31:16];
assign a3 = adda[47:32];
assign b3 = addb[47:32];
assign a4 = adda[63:48];
assign b4 = addb[63:48];

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        stage1 <= 1'b0;
        stage2 <= 1'b0;
        stage3 <= 1'b0;
        o_en <= 1'b0;
    end
    else begin
        stage1 <= i_en;
        stage2 <= stage1;
        stage3 <= stage2;
        o_en <= stage3;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        a2_ff1 <= 'd0;
        b2_ff1 <= 'd0;
        a3_ff1 <= 'd0;
        b3_ff1 <= 'd0;
        a3_ff2 <= 'd0;
        b3_ff2 <= 'd0;
        a4_ff1 <= 'd0;
        b4_ff1 <= 'd0;
        a4_ff2 <= 'd0;
        b4_ff2 <= 'd0;
        a4_ff3 <= 'd0;
        b4_ff3 <= 'd0;
    end
    else begin
        a2_ff1 <= a2;
        b2_ff1 <= b2;
        a3_ff1 <= a3;
        b3_ff1 <= b3;
        a3_ff2 <= a3_ff1;
        b3_ff2 <= b3_ff1;
        a4_ff1 <= a4;
        b4_ff1 <= b4;
        a4_ff2 <= a4_ff1;
        b4_ff2<= b4_ff1;
        a4_ff3 <= a4_ff2;
        b4_ff3 <= b4_ff2;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        s1_ff1 <= 'd0;
        s1_ff2 <= 'd0;
        s1_ff3 <= 'd0;
        s2_ff1 <= 'd0;
        s2_ff2 <= 'd0;
        s3_ff1 <= 'd0;
    end
    else begin
        s1_ff1 <= s1;
        s1_ff2 <= s1_ff1;
        s1_ff3 <= s1_ff2;
        s2_ff1 <= s2;
        s2_ff2 <= s2_ff1;
        s3_ff1 <= s3;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        c1 <= 1'b0;
        s1 <= 'd0;
    end
    else if (i_en) begin
        {c1, s1} <= a1 + b1;
    end
    else begin
        c1 <= c1;
        s1 <= s1;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        c2 <= 1'b0;
        s2 <= 'd0;
    end
    else if (stage1) begin
        {c2, s2} <= a2_ff1 + b2_ff1 + c1;
    end
    else begin
        c2 <= c2;
        s2 <= s2;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        c3 <= 1'b0;
        s3 <= 'd0;
    end
    else if (stage2) begin
        {c3, s3} <= a3_ff2 + b3_ff2 + c2;
    end
    else begin
        c3 <= c3;
        s3 <= s3;
    end
end

always @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        c4 <= 1'b0;
        s4 <= 'd0;
    end
    else if (stage3) begin
        {c4, s4} <= a4_ff3 + b4_ff3 + c3;
    end
    else begin
        c4 <= c4;
        s4 <= s4;
    end
end

assign result = {c4, s4, s3_ff1, s2_ff2, s1_ff3};

endmodule