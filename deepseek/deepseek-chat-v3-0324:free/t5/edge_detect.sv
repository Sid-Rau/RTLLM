module edge_detect (
    input clk,
    input rst_n,
    input a,
    output rise,
    output down
);

    reg a_dly;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_dly <= 1'b0;
        end else begin
            a_dly <= a;
        end
    end

    assign rise = ~a_dly & a;
    assign down = a_dly & ~a;

endmodule