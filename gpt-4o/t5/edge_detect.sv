module edge_detect (
    input wire clk,
    input wire rst_n,
    input wire a,
    output reg rise,
    output reg down
);

reg a_prev;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rise <= 0;
        down <= 0;
        a_prev <= 0;
    end else begin
        rise <= 0;
        down <= 0;
        if (a && !a_prev) begin
            rise <= 1;
        end
        if (!a && a_prev) begin
            down <= 1;
        end
        a_prev <= a;
    end
end

endmodule