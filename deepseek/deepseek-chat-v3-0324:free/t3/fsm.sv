module fsm (
    input IN,
    input CLK,
    input RST,
    output reg MATCH
);

    reg [2:0] state, next_state;
    parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;

    always @(posedge CLK or posedge RST) begin
        if (RST) state <= S0;
        else state <= next_state;
    end

    always @(*) begin
        case (state)
            S0: next_state = (IN) ? S1 : S0;
            S1: next_state = (IN) ? S1 : S2;
            S2: next_state = (IN) ? S1 : S3;
            S3: next_state = (IN) ? S4 : S0;
            S4: next_state = (IN) ? S1 : S2;
            default: next_state = S0;
        endcase
    end

    always @(*) begin
        case (state)
            S4: MATCH = (IN) ? 1'b1 : 1'b0;
            default: MATCH = 1'b0;
        endcase
    end

endmodule