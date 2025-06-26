module LFSR(
    input clk,
    input rst,
    output reg [3:0] out
);
    wire feedback;
    
    assign feedback = ~(out[3] ^ out[2]);
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 4'b0000;
        end else begin
            out <= {out[2:0], feedback};
        end
    end
endmodule