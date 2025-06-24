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
        if (RST)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    always @(*) begin
        next_state = current_state;
        MATCH = 0;
        case (current_state)
            S0: if (IN) next_state = S1;
            S1: if (!IN) next_state = S2; else next_state = S1;
            S2: if (!IN) next_state = S3; else next_state = S1;
            S3: if (IN) next_state = S4; else next_state = S1;
            S4: if (IN) begin
                    next_state = S1;
                    MATCH = 1;
                end else next_state = S2;
        endcase
    end

endmodule