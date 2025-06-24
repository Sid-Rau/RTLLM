module multi_16bit (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [15:0] ain,
    input wire [15:0] bin,
    output reg [31:0] yout,
    output reg done
);

reg [15:0] areg, breg;
reg [31:0] yout_r;
reg [4:0] i;
reg done_r;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        i <= 5'b0;
    end else if (start && i < 5'd17) begin
        i <= i + 1;
    end else if (!start) begin
        i <= 5'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        done_r <= 1'b0;
    end else if (i == 5'd16) begin
        done_r <= 1'b1;
    end else if (i == 5'd17) begin
        done_r <= 1'b0;
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        areg <= 16'b0;
        breg <= 16'b0;
        yout_r <= 32'b0;
    end else if (start) begin
        if (i == 5'b0) begin
            areg <= ain;
            breg <= bin;
            yout_r <= 32'b0;
        end else if (i < 5'd17) begin
            if (areg[i-1]) begin
                yout_r <= yout_r + (breg << (i-1));
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        yout <= 32'b0;
        done <= 1'b0;
    end else begin
        yout <= yout_r;
        done <= done_r;
    end
end

endmodule