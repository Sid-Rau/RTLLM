module mux2X1(input wire a, input wire b, input wire sel, output wire y);
    assign y = sel ? b : a;
endmodule

module barrel_shifter(input wire [7:0] in, input wire [2:0] ctrl, output wire [7:0] out);
    wire [7:0] stage1, stage2;

    // Shift by 4 positions
    mux2X1 mux0(.a(in[0]), .b(in[4]), .sel(ctrl[2]), .y(stage1[0]));
    mux2X1 mux1(.a(in[1]), .b(in[5]), .sel(ctrl[2]), .y(stage1[1]));
    mux2X1 mux2(.a(in[2]), .b(in[6]), .sel(ctrl[2]), .y(stage1[2]));
    mux2X1 mux3(.a(in[3]), .b(in[7]), .sel(ctrl[2]), .y(stage1[3]));
    mux2X1 mux4(.a(in[4]), .b(in[0]), .sel(ctrl[2]), .y(stage1[4]));
    mux2X1 mux5(.a(in[5]), .b(in[1]), .sel(ctrl[2]), .y(stage1[5]));
    mux2X1 mux6(.a(in[6]), .b(in[2]), .sel(ctrl[2]), .y(stage1[6]));
    mux2X1 mux7(.a(in[7]), .b(in[3]), .sel(ctrl[2]), .y(stage1[7]));

    // Shift by 2 positions
    mux2X1 mux8(.a(stage1[0]), .b(stage1[2]), .sel(ctrl[1]), .y(stage2[0]));
    mux2X1 mux9(.a(stage1[1]), .b(stage1[3]), .sel(ctrl[1]), .y(stage2[1]));
    mux2X1 mux10(.a(stage1[2]), .b(stage1[4]), .sel(ctrl[1]), .y(stage2[2]));
    mux2X1 mux11(.a(stage1[3]), .b(stage1[5]), .sel(ctrl[1]), .y(stage2[3]));
    mux2X1 mux12(.a(stage1[4]), .b(stage1[6]), .sel(ctrl[1]), .y(stage2[4]));
    mux2X1 mux13(.a(stage1[5]), .b(stage1[7]), .sel(ctrl[1]), .y(stage2[5]));
    mux2X1 mux14(.a(stage1[6]), .b(stage1[0]), .sel(ctrl[1]), .y(stage2[6]));
    mux2X1 mux15(.a(stage1[7]), .b(stage1[1]), .sel(ctrl[1]), .y(stage2[7]));

    // Shift by 1 position
    mux2X1 mux16(.a(stage2[0]), .b(stage2[1]), .sel(ctrl[0]), .y(out[0]));
    mux2X1 mux17(.a(stage2[1]), .b(stage2[2]), .sel(ctrl[0]), .y(out[1]));
    mux2X1 mux18(.a(stage2[2]), .b(stage2[3]), .sel(ctrl[0]), .y(out[2]));
    mux2X1 mux19(.a(stage2[3]), .b(stage2[4]), .sel(ctrl[0]), .y(out[3]));
    mux2X1 mux20(.a(stage2[4]), .b(stage2[5]), .sel(ctrl[0]), .y(out[4]));
    mux2X1 mux21(.a(stage2[5]), .b(stage2[6]), .sel(ctrl[0]), .y(out[5]));
    mux2X1 mux22(.a(stage2[6]), .b(stage2[7]), .sel(ctrl[0]), .y(out[6]));
    mux2X1 mux23(.a(stage2[7]), .b(stage2[0]), .sel(ctrl[0]), .y(out[7]));
endmodule