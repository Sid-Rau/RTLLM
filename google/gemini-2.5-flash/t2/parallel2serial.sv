module parallel2serial (
    input clk,
    input rst_n,
    input [3:0] d,
    output reg valid_out,
    output reg dout
);

reg [1:0] cnt;
reg [3:0] data_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 2'd0;
        data_reg <= 4'd0;
        valid_out <= 1'b0;
        dout <= 1'b0;
    end else begin
        if (cnt == 2'd3) begin
            data_reg <= d;
            cnt <= 2'd0;
            valid_out <= 1'b1;
            dout <= d[3]; // MSB of new data
        end else begin
            cnt <= cnt + 2'd1;
            valid_out <= 1'b0;
            data_reg <= data_reg << 1;
            dout <= data_reg[3]; // MSB of shifted data
        end
    end
end

endmodule