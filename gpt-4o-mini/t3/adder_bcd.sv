module adder_bcd (
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output reg [3:0] Sum,
    output reg Cout
);
    wire [4:0] total;
    assign total = A + B + Cin;

    always @(*) begin
        if (total > 9) begin
            Sum = total + 6;
            Cout = 1;
        end else begin
            Sum = total;
            Cout = 0;
        end
    end
endmodule