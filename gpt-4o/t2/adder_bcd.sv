module adder_bcd (
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] Sum,
    output Cout
);
    wire [4:0] temp_sum;
    wire [4:0] corrected_sum;
    
    assign temp_sum = A + B + Cin;
    assign corrected_sum = temp_sum + 5'b0110;
    
    assign Sum = (temp_sum > 9) ? corrected_sum[3:0] : temp_sum[3:0];
    assign Cout = (temp_sum > 9) ? 1'b1 : 1'b0;
    
endmodule