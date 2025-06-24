module barrel_shifter(
    input [7:0] in,
    input [2:0] ctrl,
    output [7:0] out
);
    wire [7:0] shift4, shift2, shift1;

    assign shift4 = {in[3:0], in[7:4]};
    assign shift2 = {in[1:0], in[7:2]};
    assign shift1 = {in[0], in[7:1]};

    wire [7:0] mux4_out, mux2_out, mux1_out;

    assign mux4_out = ctrl[2] ? shift4 : in;
    assign mux2_out = ctrl[1] ? shift2 : mux4_out;
    assign mux1_out = ctrl[0] ? shift1 : mux2_out;

    assign out = mux1_out;

endmodule