module edge_detect (
    input clk,
    input rst_n,
    input a,
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
            rise <= (a_prev == 0 && a == 1);
            down <= (a_prev == 1 && a == 0);
            a_prev <= a;
        end
    end
endmodule