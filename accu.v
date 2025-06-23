module accu (
    input        clk,
    input        rst_n,
    input  [7:0] data_in,
    input        valid_in,
    output reg   valid_out,
    output reg [9:0] data_out
);

    // Internal registers
    reg [9:0] sum_reg;
    reg [1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum_reg   <= 10'd0;
            count     <= 2'd0;
            data_out  <= 10'd0;
            valid_out <= 1'b0;
        end else begin
            valid_out <= 1'b0; // Default low unless triggered

            if (valid_in) begin
                sum_reg <= sum_reg + data_in;
                count   <= count + 2'd1;

                if (count == 2'd3) begin
                    data_out  <= sum_reg + data_in;
                    valid_out <= 1'b1;
                    sum_reg   <= 10'd0;
                    count     <= 2'd0;
                end
            end
        end
    end

endmodule
