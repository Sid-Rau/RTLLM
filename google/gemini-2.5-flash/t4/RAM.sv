module RAM
  #(
    parameter WIDTH = 6,
    parameter DEPTH = 8
    )
   (
    input             clk,
    input             rst_n,
    input             write_en,
    input  [2:0]      write_addr,
    input  [WIDTH-1:0] write_data,
    input             read_en,
    input  [2:0]      read_addr,
    output reg [WIDTH-1:0] read_data
    );

  reg [WIDTH-1:0] mem [DEPTH-1:0];
  integer         i;

  initial begin
    for (i = 0; i < DEPTH; i = i + 1) begin
      mem[i] = {WIDTH{1'b0}};
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < DEPTH; i = i + 1) begin
        mem[i] <= {WIDTH{1'b0}};
      end
    end else if (write_en) begin
      mem[write_addr] <= write_data;
    end
  end

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      read_data <= {WIDTH{1'b0}};
    end else if (read_en) begin
      read_data <= mem[read_addr];
    end else begin
      read_data <= {WIDTH{1'b0}};
    end
  end

endmodule