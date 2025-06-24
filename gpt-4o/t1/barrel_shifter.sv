module mux2X1(input wire a, input wire b, input wire sel, output wire y);
    assign y = sel ? b : a;
endmodule

module barrel_shifter(input wire [7:0] in, input wire [2:0] ctrl, output wire [7:0] out);
    wire [7:0] stage1, stage2, stage3;

    // Stage 1: Shift by 4 positions
    mux2X1 mux1_0(.a(in[0]), .b(in[4]), .sel(ctrl[2]), .y(stage1[0]));
    mux2X1 mux1_1(.a(in[1]), .b(in[5]), .sel(ctrl[2]), .y(stage1[1]));
    mux2X1 mux1_2(.a(in[2]), .b(in[6]), .sel(ctrl[2]), .y(stage1[2]));
    mux2X1 mux1_3(.a(in[3]), .b(in[7]), .sel(ctrl[2]), .y(stage1[3]));
    mux2X1 mux1_4(.a(in[4]), .b(in[0]), .sel(ctrl[2]), .y(stage1[4]));
    mux2X1 mux1_5(.a(in[5]), .b(in[1]), .sel(ctrl[2]), .y(stage1[5]));
    mux2X1 mux1_6(.a(in[6]), .b(in[2]), .sel(ctrl[2]), .y(stage1[6]));
    mux2X1 mux1_7(.a(in[7]), .b(in[3]), .sel(ctrl[2]), .y(stage1[7]));

    // Stage 2: Shift by 2 positions
    mux2X1 mux2_0(.a(stage1[0]), .b(stage1[2]), .sel(ctrl[1]), .y(stage2[0]));
    mux2X1 mux2_1(.a(stage1[1]), .b(stage1[3]), .sel(ctrl[1]), .y(stage2[1]));
    mux2X1 mux2_2(.a(stage1[2]), .b(stage1[4]), .sel(ctrl[1]), .y(stage2[2]));
    mux2X1 mux2_3(.a(stage1[3]), .b(stage1[5]), .sel(ctrl[1]), .y(stage2[3]));
    mux2X1 mux2_4(.a(stage1[4]), .b(stage1[6]), .sel(ctrl[1]), .y(stage2[4]));
    mux2X1 mux2_5(.a(stage1[5]), .b(stage1[7]), .sel(ctrl[1]), .y(stage2[5]));
    mux2X1 mux2_6(.a(stage1[6]), .b(stage1[0]), .sel(ctrl[1]), .y(stage2[6]));
    mux2X1 mux2_7(.a(stage1[7]), .b(stage1[1]), .sel(ctrl[1]), .y(stage2[7]));

    // Stage 3: Shift by 1 position
    mux2X1 mux3_0(.a(stage2[0]), .b(stage2[1]), .sel(ctrl[0]), .y(stage3[0]));
    mux2X1 mux3_1(.a(stage2[1]), .b(stage2[2]), .sel(ctrl[0]), .y(stage3[1]));
    mux2X1 mux3_2(.a(stage2[2]), .b(stage2[3]), .sel(ctrl[0]), .y(stage3[2]));
    mux2X1 mux3_3(.a(stage2[3]), .b(stage2[4]), .sel(ctrl[0]), .y(stage3[3]));
    mux2X1 mux3_4(.a(stage2[4]), .b(stage2[5]), .sel(ctrl[0]), .y(stage3[4]));
    mux2X1 mux3_5(.a(stage2[5]), .b(stage2[6]), .sel(ctrl[0]), .y(stage3[5]));
    mux2X1 mux3_6(.a(stage2[6]), .b(stage2[7]), .sel(ctrl[0]), .y(stage3[6]));
    mux2X1 mux3_7(.a(stage2[7]), .b(stage2[0]), .sel(ctrl[0]), .y(stage3[7]));

    assign out = stage3;
endmodule