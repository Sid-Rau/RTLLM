module barrel_shifter(
    input [7:0] in,
    input [2:0] ctrl,
    output [7:0] out
);
    wire [7:0] shift4, shift2, shift1;

    assign shift4 = {in[3:0], in[7:4]};
    assign shift2 = {in[1:0], in[7:2]};
    assign shift1 = {in[0], in[7:1]};

    wire [7:0] stage1, stage2;

    assign stage1 = (ctrl[2]) ? shift4 : in;
    assign stage2 = (ctrl[1]) ? shift2 : stage1;
    assign out = (ctrl[0]) ? shift1 : stage2;

endmodule