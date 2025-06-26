module multi_booth_8bit (
    input clk,
    input reset,
    input [7:0] a,
    input [7:0] b,
    output reg [15:0] p,
    output reg rdy
);

reg [15:0] multiplicand;
reg [15:0] multiplier;
reg [4:0] ctr;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        multiplicand <= {{8{a[7]}}, a};
        multiplier <= {{8{b[7]}}, b};
        p <= 16'd0;
        ctr <= 5'd0;
        rdy <= 1'b0;
    end else begin
        if (ctr < 5'd16) begin
            if (multiplier[0]) begin // Check the LSB of the multiplier for Booth encoding
                p <= p + multiplicand;
            end
            multiplicand <= multiplicand << 1; // Left shift multiplicand
            multiplier <= multiplier >> 1;     // Right shift multiplier
            ctr <= ctr + 5'd1;
            rdy <= 1'b0;
        end else begin
            rdy <= 1'b1;
        end
    end
end

endmodule