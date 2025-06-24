module pulse_detect (
    input clk,
    input rst_n,
    input data_in,
    output reg data_out
);
    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 2'b00;
            data_out <= 0;
        end else begin
            case (state)
                2'b00: begin
                    if (data_in) begin
                        state <= 2'b01;
                        data_out <= 0;
                    end
                end
                2'b01: begin
                    if (!data_in) begin
                        state <= 2'b10;
                        data_out <= 0;
                    end
                end
                2'b10: begin
                    if (data_in) begin
                        state <= 2'b01;
                        data_out <= 0;
                    end else begin
                        state <= 2'b00;
                        data_out <= 1;
                    end
                end
            endcase
        end
    end
endmodule