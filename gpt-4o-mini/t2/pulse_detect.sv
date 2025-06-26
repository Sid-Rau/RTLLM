module pulse_detect(
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);
    reg [1:0] state;
    parameter IDLE = 2'b00, HIGH = 2'b01, LOW = 2'b10;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            data_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (data_in) begin
                        state <= HIGH;
                        data_out <= 0;
                    end
                end
                HIGH: begin
                    if (!data_in) begin
                        state <= LOW;
                    end
                end
                LOW: begin
                    if (data_in) begin
                        data_out <= 1;
                        state <= HIGH;
                    end else begin
                        state <= IDLE;
                        data_out <= 0;
                    end
                end
            endcase
        end
    end
endmodule