module barrel_shifter(
    input [7:0] in,
    input [2:0] ctrl,
    output [7:0] out
);

wire [7:0] stage1;
wire [7:0] stage2;

mux2X1 mux_stage4_0 (.in0(in[0]), .in1(in[4]), .sel(ctrl[2]), .out(stage1[0]));
mux2X1 mux_stage4_1 (.in0(in[1]), .in1(in[5]), .sel(ctrl[2]), .out(stage1[1]));
mux2X1 mux_stage4_2 (.in0(in[2]), .in1(in[6]), .sel(ctrl[2]), .out(stage1[2]));
mux2X1 mux_stage4_3 (.in0(in[3]), .in1(in[7]), .sel(ctrl[2]), .out(stage1[3]));
mux2X1 mux_stage4_4 (.in0(in[4]), .in1(in[0]), .sel(ctrl[2]), .out(stage1[4]));
mux2X1 mux_stage4_5 (.in0(in[5]), .in1(in[1]), .sel(ctrl[2]), .out(stage1[5]));
mux2X1 mux_stage4_6 (.in0(in[6]), .in1(in[2]), .sel(ctrl[2]), .out(stage1[6]));
mux2X1 mux_stage4_7 (.in0(in[7]), .in1(in[3]), .sel(ctrl[2]), .out(stage1[7]));

mux2X1 mux_stage2_0 (.in0(stage1[0]), .in1(stage1[2]), .sel(ctrl[1]), .out(stage2[0]));
mux2X1 mux_stage2_1 (.in0(stage1[1]), .in1(stage1[3]), .sel(ctrl[1]), .out(stage2[1]));
mux2X1 mux_stage2_2 (.in0(stage1[2]), .in1(stage1[4]), .sel(ctrl[1]), .out(stage2[2]));
mux2X1 mux_stage2_3 (.in0(stage1[3]), .in1(stage1[5]), .sel(ctrl[1]), .out(stage2[3]));
mux2X1 mux_stage2_4 (.in0(stage1[4]), .in1(stage1[6]), .sel(ctrl[1]), .out(stage2[4]));
mux2X1 mux_stage2_5 (.in0(stage1[5]), .in1(stage1[7]), .sel(ctrl[1]), .out(stage2[5]));
mux2X1 mux_stage2_6 (.in0(stage1[6]), .in1(stage1[0]), .sel(ctrl[1]), .out(stage2[6]));
mux2X1 mux_stage2_7 (.in0(stage1[7]), .in1(stage1[1]), .sel(ctrl[1]), .out(stage2[7]));

mux2X1 mux_stage1_0 (.in0(stage2[0]), .in1(stage2[1]), .sel(ctrl[0]), .out(out[0]));
mux2X1 mux_stage1_1 (.in0(stage2[1]), .in1(stage2[2]), .sel(ctrl[0]), .out(out[1]));
mux2X1 mux_stage1_2 (.in0(stage2[2]), .in1(stage2[3]), .sel(ctrl[0]), .out(out[2]));
mux2X1 mux_stage1_3 (.in0(stage2[3]), .in1(stage2[4]), .sel(ctrl[0]), .out(out[3]));
mux2X1 mux_stage1_4 (.in0(stage2[4]), .in1(stage2[5]), .sel(ctrl[0]), .out(out[4]));
mux2X1 mux_stage1_5 (.in0(stage2[5]), .in1(stage2[6]), .sel(ctrl[0]), .out(out[5]));
mux2X1 mux_stage1_6 (.in0(stage2[6]), .in1(stage2[7]), .sel(ctrl[0]), .out(out[6]));
mux2X1 mux_stage1_7 (.in0(stage2[7]), .in1(stage2[0]), .sel(ctrl[0]), .out(out[7]));

endmodule

module mux2X1(
    input in0,
    input in1,
    input sel,
    output out
);

assign out = sel ? in1 : in0;

endmodule