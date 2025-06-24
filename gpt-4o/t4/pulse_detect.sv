module pulse_detect (
    input wire clk,
    input wire rst_n,
    input wire data_in,
    output reg data_out
);

    reg [1:0] state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 2'b00;
            data_out <= 1'b0;
        end else begin
            case (state)
                2'b00: begin
                    if (data_in)
                        state <= 2'b01;
                end
                2'b01: begin
                    if (!data_in)
                        state <= 2'b10;
                end
                2'b10: begin
                    if (data_in)
                        state <= 2'b11;
                    else
                        state <= 2'b00;
                end
                2'b11: begin
                    if (!data_in) begin
                        data_out <= 1'b1;
                        state <= 2'b00;
                    end
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 1'b0;
        end else if (state == 2'b11 && !data_in) begin
            data_out <= 1'b1;
        end else begin
            data_out <= 1'b0;
        end
    end

endmodule