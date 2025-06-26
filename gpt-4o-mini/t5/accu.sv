module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);
    reg [9:0] sum;
    reg [1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum <= 10'b0;
            count <= 2'b0;
            valid_out <= 1'b0;
        end else if (valid_in) begin
            sum <= sum + data_in;
            count <= count + 1;
            if (count == 2'b11) begin
                valid_out <= 1'b1;
                data_out <= sum;
                sum <= 10'b0;
                count <= 2'b0;
            end else begin
                valid_out <= 1'b0;
            end
        end
    end
endmodule