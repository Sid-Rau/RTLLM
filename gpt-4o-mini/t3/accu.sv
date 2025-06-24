module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);
    reg [7:0] data_buffer[0:3];
    reg [1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 2'b00;
            valid_out <= 1'b0;
            data_out <= 10'b0;
        end else if (valid_in) begin
            if (count < 2'b11) begin
                data_buffer[count] <= data_in;
                count <= count + 1;
                valid_out <= 1'b0;
            end
            if (count == 2'b11) begin
                data_out <= data_buffer[0] + data_buffer[1] + data_buffer[2] + data_buffer[3];
                valid_out <= 1'b1;
                count <= 2'b00;
            end
        end
    end
endmodule