module width_8to16 (
  input wire clk,
  input wire rst_n,
  input wire valid_in,
  input wire [7:0] data_in,
  output reg valid_out,
  output reg [15:0] data_out
);

reg [7:0] data_lock;
reg flag;

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    data_out <= 16'b0;
    valid_out <= 1'b0;
    data_lock <= 8'b0;
    flag <= 1'b0;
  end else begin
    valid_out <= 1'b0; // Default to not valid

    if (valid_in) begin
      if (flag) begin // Second data arrived
        data_out <= {data_lock, data_in};
        valid_out <= 1'b1;
        flag <= 1'b0; // Reset flag for next pair
      end else begin // First data arrived
        data_lock <= data_in;
        flag <= 1'b1; // Set flag to indicate first data is stored
      end
    end
  end
end

endmodule