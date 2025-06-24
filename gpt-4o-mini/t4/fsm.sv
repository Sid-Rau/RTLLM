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
        end
    end

    always @(*) begin
        case (current_state)
            S0: begin
                MATCH = 0;
                if (IN) next_state = S1; else next_state = S0;
            end
            S1: begin
                MATCH = 0;
                if (!IN) next_state = S2; else next_state = S1;
            end
            S2: begin
                MATCH = 0;
                if (!IN) next_state = S3; else next_state = S1;
            end
            S3: begin
                MATCH = 0;
                if (IN) next_state = S4; else next_state = S0;
            end
            S4: begin
                MATCH = 1;
                if (IN) next_state = S4; else next_state = S0;
            end
            default: begin
                MATCH = 0;
                next_state = S0;
            end
        endcase
    end
endmodule