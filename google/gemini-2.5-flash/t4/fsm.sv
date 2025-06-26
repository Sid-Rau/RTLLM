module fsm (
  input IN,
  input CLK,
  input RST,
  output reg MATCH
);

  parameter S0 = 3'b000;
  parameter S1 = 3'b001;
  parameter S2 = 3'b010;
  parameter S3 = 3'b011;
  parameter S4 = 3'b100;
  parameter S5 = 3'b101;

  reg [2:0] current_state;
  reg [2:0] next_state;

  always @(posedge CLK or posedge RST) begin
    if (RST) begin
      current_state <= S0;
    end else begin
      current_state <= next_state;
    end
  end

  always @(*) begin
    MATCH = 1'b0; 
    next_state = current_state;

    case (current_state)
      S0: begin
        if (IN == 1'b1) begin
          next_state = S1;
        end else begin
          next_state = S0;
        end
      end
      S1: begin
        if (IN == 1'b0) begin
          next_state = S2;
        end else begin
          next_state = S1; 
        end
      end
      S2: begin
        if (IN == 1'b0) begin
          next_state = S3;
        end else begin
          next_state = S1; 
        end
      end
      S3: begin
        if (IN == 1'b1) begin
          next_state = S4;
        end else begin
          next_state = S0; 
        end
      end
      S4: begin
        if (IN == 1'b1) begin
          MATCH = 1'b1;
          next_state = S1; 
        end else begin
          next_state = S2; 
        end
      end
      default: begin
        next_state = S0;
        MATCH = 1'b0;
      end
    endcase
  end

endmodule