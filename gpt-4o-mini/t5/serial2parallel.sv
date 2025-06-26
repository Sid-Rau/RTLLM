module serial2parallel(
    input clk,
    input rst_n,
    input din_serial,
    input din_valid,
    output reg [7:0] dout_parallel,
    output reg dout_valid
);
    reg [3:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dout_parallel <= 8'b0;
            dout_valid <= 1'b0;
            cnt <= 4'b0;
        end else if (din_valid) begin
            dout_parallel <= {dout_parallel[6:0], din_serial};
            cnt <= cnt + 1;
            if (cnt == 4'd7) begin
                dout_valid <= 1'b1;
                cnt <= 4'b0;
            end else begin
                dout_valid <= 1'b0;
            end
        end
    end
endmodule