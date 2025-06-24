module multi_16bit(
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

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 0;
            done <= 0;
            yout_r <= 0;
            areg <= 0;
            breg <= 0;
        end else begin
            if (start) begin
                if (i == 0) begin
                    areg <= ain;
                    breg <= bin;
                end
                if (i < 17) begin
                    if (i > 0 && areg[i-1]) begin
                        yout_r <= yout_r + (breg << (i-1));
                    end
                    i <= i + 1;
                end
                if (i == 16) begin
                    done <= 1;
                end
                if (i == 17) begin
                    done <= 0;
                end
            end else begin
                i <= 0;
            end
        end
    end

    always @(posedge clk) begin
        yout <= yout_r;
    end
endmodule