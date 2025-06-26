module adder_bcd (
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output reg [3:0] Sum,
    output reg Cout
);

    reg [4:0] temp_sum;

    always @(*) begin
        temp_sum = A + B + Cin;
        if (temp_sum > 9) begin
            temp_sum = temp_sum + 6;
            Cout = 1;
        end else begin
            Cout = 0;
        end
        Sum = temp_sum[3:0];
    end

endmodule