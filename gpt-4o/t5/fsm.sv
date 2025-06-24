module fsm (
    input wire IN,
    input wire CLK,
    input wire RST,
    output reg MATCH
);

    typedef enum reg [2:0] {
        S0, S1, S2, S3, S4
    } state_t;

    state_t state, next_state;

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            state <= S0;
            MATCH <= 0;
        end else begin
            state <= next_state;
        end
    end

    always @(*) begin
        MATCH = 0;
        case (state)
            S0: begin
                if (IN) next_state = S1;
                else next_state = S0;
            end
            S1: begin
                if (~IN) next_state = S2;
                else next_state = S1;
            end
            S2: begin
                if (~IN) next_state = S3;
                else next_state = S1;
            end
            S3: begin
                if (IN) next_state = S4;
                else next_state = S0;
            end
            S4: begin
                if (IN) begin
                    next_state = S1;
                    MATCH = 1;
                end else next_state = S2;
            end
            default: next_state = S0;
        endcase
    end

endmodule