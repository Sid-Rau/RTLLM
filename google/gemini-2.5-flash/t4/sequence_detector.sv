module sequence_detector (
  input clk,
  input rst_n,
  input data_in,
  output reg sequence_detected
);

  // State definitions
  typedef enum logic [2:0] {
    IDLE,
    S1,
    S2,
    S3,
    S4
  } state_t;

  state_t current_state, next_state;

  // FSM state register
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  // Next state logic
  always_comb begin
    next_state = current_state; // Default to staying in current state
    sequence_detected = 1'b0;   // Default output

    case (current_state)
      IDLE: begin
        if (data_in == 1'b1) begin
          next_state = S1;
        end else begin
          next_state = IDLE;
        end
      end
      S1: begin // Expecting 0 (10)
        if (data_in == 1'b0) begin
          next_state = S2;
        end else begin // If 1, stay in S1 (1->1)
          next_state = S1;
        end
      end
      S2: begin // Expecting 0 (100)
        if (data_in == 1'b0) begin
          next_state = S3;
        end else begin // If 1, go back to S1 (10->1)
          next_state = S1;
        end
      end
      S3: begin // Expecting 1 (1001)
        if (data_in == 1'b1) begin
          next_state = S4;
        end else begin // If 0, go back to IDLE or S2 (100->0)
          next_state = IDLE; // If 0, no partial match, restart
        end
      end
      S4: begin // Sequence detected, reset for next detection
        sequence_detected = 1'b1;
        if (data_in == 1'b1) begin // If next bit is 1, potentially start new sequence
          next_state = S1;
        end else begin // If next bit is 0, no partial match
          next_state = IDLE;
        end
      end
      default: begin
        next_state = IDLE;
      end
    endcase
  end

endmodule