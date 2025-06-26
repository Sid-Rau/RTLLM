module fsm (
    input IN,
    input CLK,
    input RST,
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

    always @(current_state or IN) begin
        case (current_state)
            S0: begin
                if (IN) next_state = S1;
                else next_state = S0;
                MATCH = 0;
            end
            S1: begin
                if (!IN) next_state = S2;
                else next_state = S1;
                MATCH = 0;
            end
            S2: begin
                if (!IN) next_state = S3;
                else next_state = S1;
                MATCH = 0;
            end
            S3: begin
                if (IN) next_state = S4;
                else next_state = S0;
                MATCH = 0;
            end
            S4: begin
                if (IN) begin
                    MATCH = 1;
                    next_state = S1;
                end else begin
                    MATCH = 0;
                    next_state = S0;
                end
            end
            default: begin
                next_state = S0;
                MATCH = 0;
            end
        endcase
    end
endmodule