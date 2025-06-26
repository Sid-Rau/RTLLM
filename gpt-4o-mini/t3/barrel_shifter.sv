module barrel_shifter (
    input [7:0] in,
    input [2:0] ctrl,
    output [7:0] out
);
    wire [7:0] shift4, shift2, shift1;
    wire [7:0] mux4_out, mux2_out, mux1_out;

    assign shift4 = {in[3:0], in[7:4]};
    assign shift2 = {in[5:0], in[7:6]};
    assign shift1 = {in[6:0], in[7]};

    mux2X1 mux4(.a(in), .b(shift4), .sel(ctrl[2]), .y(mux4_out));
    mux2X1 mux2(.a(mux4_out), .b(shift2), .sel(ctrl[1]), .y(mux2_out));
    mux2X1 mux1(.a(mux2_out), .b(shift1), .sel(ctrl[0]), .y(out));

endmodule

module mux2X1 (
    input [7:0] a,
    input [7:0] b,
    input sel,
    output [7:0] y
);
    assign y = sel ? b : a;
endmodule