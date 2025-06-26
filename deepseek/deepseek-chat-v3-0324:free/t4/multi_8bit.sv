module multi_8bit (
    input [7:0] A,
    input [7:0] B,
    output reg [15:0] product
);

    reg [15:0] temp_A;
    integer i;

    always @* begin
        product = 16'b0;
        temp_A = {8'b0, A};

        for (i = 0; i < 8; i = i + 1) begin
            if (B[i]) begin
                product = product + (temp_A << i);
            end
        end
    end

endmodule