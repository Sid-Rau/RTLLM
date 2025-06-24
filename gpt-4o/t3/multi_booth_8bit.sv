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
            multiplicand <= {{8{b[7]}}, b};
            multiplier <= {{8{a[7]}}, a};
            p <= 16'b0;
            ctr <= 5'b0;
            rdy <= 0;
        end else begin
            if (ctr < 5'd16) begin
                if (multiplier[ctr]) begin
                    p <= p + multiplicand;
                end
                multiplicand <= multiplicand << 1;
                ctr <= ctr + 1;
            end else begin
                rdy <= 1;
            end
        end
    end
endmodule