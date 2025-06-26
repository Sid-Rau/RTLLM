module signal_generator (
  input clk,
  input rst_n,
  output reg [4:0] wave
);

  reg state; // 0 for incrementing, 1 for decrementing

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= 0;
      wave <= 0;
    end else begin
      case (state)
        0: begin // Incrementing
          if (wave == 5'd31) begin
            state <= 1;
            wave <= wave - 1; // Start decrementing from 30
          end else begin
            wave <= wave + 1;
          end
        end
        1: begin // Decrementing
          if (wave == 5'd0) begin
            state <= 0;
            wave <= wave + 1; // Start incrementing from 1
          end else begin
            wave <= wave - 1;
          end
        end
      endcase
    end
  end

endmodule