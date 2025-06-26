module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

    reg [2:0] state, next_state;
    parameter S0 = 3'b000,
              S1 = 3'b001,
              S2 = 3'b010,
              S3 = 3'b011,
              S4 = 3'b100;

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            state <= S0;
            MATCH <= 0;
        end
        else begin
            state <= next_state;
            if (next_state == S4 && IN == 1)
                MATCH <= 1;
            else
                MATCH <= 0;
        end
    end

    always @(*) begin
        case (state)
            S0: next_state = (IN == 1) ? S1 : S0;
            S1: next_state = (IN == 0) ? S2 : S1;
            S2: next_state = (IN == 0) ? S3 : (IN == 1) ? S1 : S2;
            S3: next_state = (IN == 1) ? S4 : S0;
            S4: next_state = (IN == 1) ? S1 : S2;
            default: next_state = S0;
        endcase
    end

endmodule