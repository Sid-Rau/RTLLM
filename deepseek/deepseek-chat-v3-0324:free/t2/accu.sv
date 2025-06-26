module accu (
    input clk,
    input rst_n,
    input [7:0] data_in,
    input valid_in,
    output reg [9:0] data_out,
    output reg valid_out
);

reg [1:0] cnt;
reg [9:0] sum;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 2'b0;
        sum <= 10'b0;
        data_out <= 10'b0;
        valid_out <= 1'b0;
    end
    else begin
        if (valid_in) begin
            sum <= sum + data_in;
            cnt <= cnt + 1'b1;
            if (cnt == 2'b11) begin
                data_out <= sum + data_in;
                valid_out <= 1'b1;
                sum <= 10'b0;
                cnt <= 2'b0;
            end
            else begin
                valid_out <= 1'b0;
            end
        end
        else begin
            valid_out <= 1'b0;
        end
    end
end

endmodule