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
        multiplicand <= { {8{a[7]}}, a };
        multiplier <= { {8{b[7]}}, b };
        p <= 16'd0;
        ctr <= 5'd0;
        rdy <= 1'b0;
    end else begin
        if (ctr < 5'd16) begin
            rdy <= 1'b0;
            case (multiplier[1:0])
                2'b01: begin // 01: Add multiplicand
                    p <= p + multiplicand;
                end
                2'b10: begin // 10: Subtract multiplicand
                    p <= p - multiplicand;
                end
                default: begin // 00 or 11: No operation
                    p <= p;
                end
            endcase
            
            p <= p >>> 1; // Arithmetic right shift
            multiplier <= multiplier >>> 2; // Right shift multiplier by 2 for Radix-4
            
            ctr <= ctr + 5'd1;
        end else begin
            rdy <= 1'b1;
        end
    end
end

endmodule