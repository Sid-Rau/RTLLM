module accu (
    input wire clk,
    input wire rst_n,
    input wire [7:0] data_in,
    input wire valid_in,
    output reg valid_out,
    output reg [9:0] data_out
);

reg [1:0] count;
reg [9:0] sum;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count <= 2'b00;
        sum <= 10'b0;
        valid_out <= 1'b0;
        data_out <= 10'b0;
    end else begin
        valid_out <= 1'b0; // Default to 0, set to 1 only when condition met

        if (valid_in) begin
            if (count == 2'd3) begin
                // Fourth data received, calculate final sum and output
                sum <= sum + data_in;
                data_out <= sum + data_in;
                valid_out <= 1'b1;
                count <= 2'b00; // Reset count for next accumulation
                sum <= 10'b0;   // Reset sum for next accumulation
            end else begin
                // Accumulate data
                sum <= sum + data_in;
                count <= count + 2'b01;
            end
        end
    end
end

endmodule