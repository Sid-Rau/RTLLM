module fsm (
    input wire IN,
    input wire CLK,
    input wire RST,
    output reg MATCH
);
    typedef enum reg [2:0] {
        S0, S1, S2, S3, S4
    } state_t;

    state_t current_state, next_state;

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            current_state <= S0;
            MATCH <= 0;
        end else begin
            current_state <= next_state;
            MATCH <= (next_state == S4) ? 1 : 0;
        end
    end

    always @(*) begin
        case (current_state)
            S0: next_state = (IN) ? S1 : S0;
            S1: next_state = (IN) ? S1 : S2;
            S2: next_state = (IN) ? S3 : S0;
            S3: next_state = (IN) ? S1 : S4;
            S4: next_state = (IN) ? S1 : S0;
            default: next_state = S0;
        endcase
    end
endmodule