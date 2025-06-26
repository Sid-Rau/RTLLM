module signal_generator (
  input clk,
  input rst_n,
  output reg [4:0] wave
);

  reg state; // 0 for incrementing, 1 for decrementing

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= 1'b0;
      wave <= 5'b0;
    end else begin
      case (state)
        1'b0: begin // Incrementing
          if (wave == 5'd31) begin
            state <= 1'b1;
            wave <= wave - 5'd1; // Start decrementing from 30
          end else begin
            wave <= wave + 5'd1;
          end
        end
        1'b1: begin // Decrementing
          if (wave == 5'd0) begin
            state <= 1'b0;
            wave <= wave + 5'd1; // Start incrementing from 1
          end else begin
            wave <= wave - 5'd1;
          end
        end
      endcase
    end
  end

endmodule