module barrel_shifter (
    input [7:0] in,
    input [2:0] ctrl,
    output [7:0] out
);
    wire [7:0] shift4, shift2, shift1;

    assign shift4 = {in[3:0], in[7:4]};
    assign shift2 = {in[1:0], in[7:2]};
    assign shift1 = {in[0], in[7:1]};

    assign out = (ctrl[2] ? shift4 :
                 (ctrl[1] ? shift2 :
                 (ctrl[0] ? shift1 : in)));

endmodule