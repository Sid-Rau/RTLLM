module signal_generator (
    input wire clk,
    input wire rst_n,
    output reg [4:0] wave
);

    reg state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wave <= 5'b00000;
            state <= 1'b0;
        end else begin
            case (state)
                1'b0: begin
                    if (wave == 5'b11111) begin
                        state <= 1'b1;
                    end else begin
                        wave <= wave + 1'b1;
                    end
                end
                1'b1: begin
                    if (wave == 5'b00000) begin
                        state <= 1'b0;
                    end else begin
                        wave <= wave - 1'b1;
                    end
                end
            endcase
        end
    end

endmodule