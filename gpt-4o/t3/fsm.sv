module fsm (
    input wire IN,
    input wire CLK,
    input wire RST,
    output reg MATCH
);

    typedef enum logic [2:0] {
        S0 = 3'b000,
        S1 = 3'b001,
        S2 = 3'b010,
        S3 = 3'b011,
        S4 = 3'b100
    } state_t;

    state_t state, next_state;

    always_ff @(posedge CLK or posedge RST) begin
        if (RST)
            state <= S0;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        MATCH = 1'b0;
        case (state)
            S0: if (IN) next_state = S1;
            S1: if (~IN) next_state = S2;
            S2: if (~IN) next_state = S3;
            S3: if (IN) next_state = S4;
            S4: begin
                if (IN) begin
                    MATCH = 1'b1;
                    next_state = S1;
                end else begin
                    next_state = S0;
                end
            end
            default: next_state = S0;
        endcase
    end

endmodule