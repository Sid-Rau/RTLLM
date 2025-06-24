module multi_16bit (
    input clk,
    input rst_n,
    input start,
    input [15:0] ain,
    input [15:0] bin,
    output reg [31:0] yout,
    output reg done
);
    reg [15:0] areg, breg;
    reg [31:0] yout_r;
    reg [4:0] i;
    reg done_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 0;
            done_r <= 0;
            yout_r <= 0;
            areg <= 0;
            breg <= 0;
        end else begin
            if (start) begin
                if (i < 16) begin
                    i <= i + 1;
                end
            end else begin
                i <= 0;
            end
            
            if (i == 0) begin
                areg <= ain;
                breg <= bin;
                yout_r <= 0;
            end else if (i > 0 && i < 17) begin
                if (areg[i-1]) begin
                    yout_r <= yout_r + (breg << (i-1));
                end
            end
            
            if (i == 16) begin
                done_r <= 1;
            end else if (i == 17) begin
                done_r <= 0;
            end
        end
    end

    always @(posedge clk) begin
        yout <= yout_r;
        done <= done_r;
    end
endmodule