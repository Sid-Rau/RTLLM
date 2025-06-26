module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);
    reg [7:0] data_buffer [0:3];
    reg [1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            valid_out <= 0;
            data_out <= 0;
        end else if (valid_in) begin
            if (count < 4) begin
                data_buffer[count] <= data_in;
                count <= count + 1;
                valid_out <= 0;
            end
            if (count == 3) begin
                data_out <= data_buffer[0] + data_buffer[1] + data_buffer[2] + data_buffer[3];
                valid_out <= 1;
                count <= 0; // Reset count to accumulate next 4 data
            end
        end else begin
            valid_out <= 0;
        end
    end
endmodule