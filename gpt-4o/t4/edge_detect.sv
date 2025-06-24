module edge_detect (
    input wire clk,
    input wire rst_n,
    input wire a,
    output reg rise,
    output reg down
);

reg a_d;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        a_d <= 1'b0;
        rise <= 1'b0;
        down <= 1'b0;
    end else begin
        rise <= 1'b0;
        down <= 1'b0;
        if (a && !a_d) begin
            rise <= 1'b1;
        end else if (!a && a_d) begin
            down <= 1'b1;
        end
        a_d <= a;
    end
end

endmodule