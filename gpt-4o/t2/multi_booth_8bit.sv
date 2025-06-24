module multi_booth_8bit(
    input clk,
    input reset,
    input [7:0] a,
    input [7:0] b,
    output reg [15:0] p,
    output reg rdy
);

    reg [15:0] multiplier;
    reg [15:0] multiplicand;
    reg [4:0] ctr;
    reg [15:0] acc;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            multiplier <= {{8{a[7]}}, a};
            multiplicand <= {{8{b[7]}}, b};
            acc <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
        end else begin
            if (ctr < 16) begin
                if (multiplier[ctr])
                    acc <= acc + multiplicand;
                multiplicand <= multiplicand << 1;
                ctr <= ctr + 1;
            end else begin
                p <= acc;
                rdy <= 1'b1;
            end
        end
    end

endmodule