module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

typedef enum logic [2:0] {
    S0,  // Initial state
    S1,  // Detected '1'
    S2,  // Detected '10'
    S3,  // Detected '100'
    S4,  // Detected '1001'
    S5   // Detected '10011'
} state_t;

state_t current_state;
state_t next_state;

always_ff @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= S0;
    end else begin
        current_state <= next_state;
    end
end

always_comb begin
    next_state = current_state;
    MATCH = 1'b0; 

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
                next_state = S1; // Stays in S1 if another '1' comes
            end
        end
        S2: begin
            if (IN == 1'b0) begin
                next_state = S3;
            end else begin
                next_state = S1; // If '1' comes, restart from S1
            end
        end
        S3: begin
            if (IN == 1'b1) begin
                next_state = S4;
            end else begin
                next_state = S0; // If '0' comes, restart from S0
            end
        end
        S4: begin
            if (IN == 1'b1) begin
                next_state = S5;
            end else begin
                next_state = S2; // If '0' comes, we have '100', so go to S2
            end
        end
        S5: begin
            MATCH = 1'b1; // Output MATCH is 1 when in S5
            if (IN == 1'b1) begin
                next_state = S1; // If '1' comes, restart from S1 (for '100111' -> '1' is the start of new sequence)
            end else begin
                next_state = S2; // If '0' comes, we have '100110', so go to S2 (for '100110' -> '10' is the start of new sequence)
            end
        end
    endcase
end

endmodule