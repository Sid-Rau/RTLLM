module sequence_detector (
  input clk,
  input rst_n,
  input data_in,
  output reg sequence_detected
);

  // State encoding
  localparam IDLE = 3'b000;
  localparam S1   = 3'b001;
  localparam S2   = 3'b010;
  localparam S3   = 3'b011;
  localparam S4   = 3'b100;

  reg [2:0] current_state;
  reg [2:0] next_state;

  // State register
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  // Next state logic
  always @(*) begin
    next_state = current_state; // Default to staying in current state
    sequence_detected = 1'b0;   // Default to no detection

    case (current_state)
      IDLE: begin
        if (data_in == 1'b1) begin // Looking for '1'
          next_state = S1;
        end else begin
          next_state = IDLE;
        end
      end
      S1: begin
        if (data_in == 1'b0) begin // Looking for '0'
          next_state = S2;
        end else begin // If '1' received, stay in S1 (overlapping sequence)
          next_state = S1;
        end
      end
      S2: begin
        if (data_in == 1'b0) begin // Looking for '0'
          next_state = S3;
        end else begin // If '1' received, go back to S1 (overlapping sequence)
          next_state = S1;
        end
      end
      S3: begin
        if (data_in == 1'b1) begin // Looking for '1'
          next_state = S4;
        end else begin // If '0' received, go back to IDLE (no overlap for 1001)
          next_state = IDLE;
        end
      end
      S4: begin
        sequence_detected = 1'b1; // Sequence 1001 detected
        if (data_in == 1'b1) begin // If '1' received after detection, could be start of new sequence
          next_state = S1;
        end else begin // If '0' received after detection, go back to IDLE
          next_state = IDLE;
        end
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end

endmodule