module square_wave(
    input wire clk,
    input wire [7:0] freq,
    output reg wave_out
);
    reg [7:0] count;

    always @(posedge clk) begin
        if (count >= (freq - 1)) begin
            count <= 8'd0;
            wave_out <= ~wave_out;
        end else begin
            count <= count + 8'd1;
        end
    end
endmodule