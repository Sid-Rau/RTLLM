module signal_generator (
    input wire clk,
    input wire rst_n,
    output reg [4:0] wave
);

reg state;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= 0;
        wave <= 5'd0;
    end else begin
        case (state)
            1'b0: begin
                wave <= wave + 5'd1;
                if (wave == 5'd31) state <= 1'b1;
            end
            1'b1: begin
                wave <= wave - 5'd1;
                if (wave == 5'd0) state <= 1'b0;
            end
        endcase
    end
end

endmodule