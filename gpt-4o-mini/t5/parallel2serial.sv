module parallel2serial (
    input clk,
    input rst_n,
    input [3:0] d,
    output reg valid_out,
    output reg dout
);
    reg [1:0] cnt;
    reg [3:0] data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            valid_out <= 0;
            dout <= 0;
            data <= 0;
        end else begin
            if (cnt == 3) begin
                data <= d;
                cnt <= 0;
                valid_out <= 1;
            end else begin
                dout <= data[3];
                data <= {data[2:0], 1'b0};
                cnt <= cnt + 1;
                valid_out <= 0;
            end
        end
    end
endmodule