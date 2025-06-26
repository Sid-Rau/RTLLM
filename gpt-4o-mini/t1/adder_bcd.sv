module adder_bcd (
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output reg [3:0] Sum,
    output reg Cout
);
    wire [4:0] total;
    wire correction;

    assign total = A + B + Cin;
    assign correction = total > 9;

    always @(*) begin
        if (correction) begin
            Sum = total + 6;
            Cout = 1;
        end else begin
            Sum = total;
            Cout = 0;
        end
    end
endmodule