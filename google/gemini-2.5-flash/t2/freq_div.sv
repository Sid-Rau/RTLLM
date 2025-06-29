module freq_div (
  input CLK_in,
  input RST,
  output reg CLK_50,
  output reg CLK_10,
  output reg CLK_1
);

reg [3:0] cnt_10;
reg [6:0] cnt_100;

always @(posedge CLK_in or posedge RST) begin
  if (RST) begin
    CLK_50 <= 1'b0;
  end else begin
    CLK_50 <= ~CLK_50;
  end
end

always @(posedge CLK_in or posedge RST) begin
  if (RST) begin
    CLK_10 <= 1'b0;
    cnt_10 <= 4'd0;
  end else begin
    if (cnt_10 == 4) begin
      CLK_10 <= ~CLK_10;
      cnt_10 <= 4'd0;
    end else begin
      cnt_10 <= cnt_10 + 4'd1;
    end
  end
end

always @(posedge CLK_in or posedge RST) begin
  if (RST) begin
    CLK_1 <= 1'b0;
    cnt_100 <= 7'd0;
  end else begin
    if (cnt_100 == 49) begin
      CLK_1 <= ~CLK_1;
      cnt_100 <= 7'd0;
    end else begin
      cnt_100 <= cnt_100 + 7'd1;
    end
  end
end

endmodule