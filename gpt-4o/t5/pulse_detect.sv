module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);

    reg [1:0] state;
    reg [1:0] next_state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= 2'b00;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            2'b00: begin
                if (data_in)
                    next_state = 2'b01;
                else
                    next_state = 2'b00;
                data_out = 0;
            end
            2'b01: begin
                if (!data_in)
                    next_state = 2'b10;
                else
                    next_state = 2'b01;
                data_out = 0;
            end
            2'b10: begin
                if (data_in)
                    next_state = 2'b01;
                else
                    next_state = 2'b00;
                data_out = 1;
            end
            default: begin
                next_state = 2'b00;
                data_out = 0;
            end
        endcase
    end

endmodule