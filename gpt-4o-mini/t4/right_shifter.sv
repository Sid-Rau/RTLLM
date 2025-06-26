module right_shifter(
    input clk,
    input d,
    output reg [7:0] q
);
    initial begin
        q = 8'b00000000;
    end
    
    always @(posedge clk) begin
        q <= {d, q[7:1]};
    end
endmodule