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
        if (RST) begin
            state <= S0;
            MATCH <= 0;
        end
        else begin
            state <= next_state;
        end
    end

    always @(*) begin
        case (state)
            S0: begin
                MATCH = 0;
                if (IN) next_state = S1;
                else next_state = S0;
            end
            S1: begin
                MATCH = 0;
                if (!IN) next_state = S2;
                else next_state = S1;
            end
            S2: begin
                MATCH = 0;
                if (!IN) next_state = S3;
                else next_state = S1;
            end
            S3: begin
                MATCH = 0;
                if (IN) next_state = S4;
                else next_state = S0;
            end
            S4: begin
                MATCH = IN;
                if (IN) next_state = S1;
                else next_state = S2;
            end
            default: begin
                MATCH = 0;
                next_state = S0;
            end
        endcase
    end

endmodule