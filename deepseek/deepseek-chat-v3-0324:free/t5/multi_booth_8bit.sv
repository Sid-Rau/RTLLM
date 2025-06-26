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
    reg [15:0] product;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            multiplicand <= {{8{b[7]}}, b};
            multiplier <= {{8{a[7]}}, a};
            product <= 16'b0;
            ctr <= 5'b0;
            rdy <= 1'b0;
        end else begin
            if (ctr < 16) begin
                case (multiplier[1:0])
                    2'b01: product <= product + multiplicand;
                    2'b10: product <= product - multiplicand;
                    default: product <= product;
                endcase
                multiplicand <= multiplicand << 1;
                multiplier <= multiplier >> 1;
                ctr <= ctr + 1;
                rdy <= 1'b0;
            end else begin
                rdy <= 1'b1;
                p <= product;
            end
        end
    end

endmodule