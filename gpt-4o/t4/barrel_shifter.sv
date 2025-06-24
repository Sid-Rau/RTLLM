module mux2X1(input wire a, input wire b, input wire sel, output wire y);
    assign y = sel ? b : a;
endmodule

module barrel_shifter(input wire [7:0] in, input wire [2:0] ctrl, output wire [7:0] out);
    wire [7:0] stage1, stage2;

    // Stage 1: Shift by 4 if ctrl[2] is high
    mux2X1 m0_1(in[0], in[4], ctrl[2], stage1[0]);
    mux2X1 m1_1(in[1], in[5], ctrl[2], stage1[1]);
    mux2X1 m2_1(in[2], in[6], ctrl[2], stage1[2]);
    mux2X1 m3_1(in[3], in[7], ctrl[2], stage1[3]);
    mux2X1 m4_1(in[4], in[0], ctrl[2], stage1[4]);
    mux2X1 m5_1(in[5], in[1], ctrl[2], stage1[5]);
    mux2X1 m6_1(in[6], in[2], ctrl[2], stage1[6]);
    mux2X1 m7_1(in[7], in[3], ctrl[2], stage1[7]);

    // Stage 2: Shift by 2 if ctrl[1] is high
    mux2X1 m0_2(stage1[0], stage1[2], ctrl[1], stage2[0]);
    mux2X1 m1_2(stage1[1], stage1[3], ctrl[1], stage2[1]);
    mux2X1 m2_2(stage1[2], stage1[4], ctrl[1], stage2[2]);
    mux2X1 m3_2(stage1[3], stage1[5], ctrl[1], stage2[3]);
    mux2X1 m4_2(stage1[4], stage1[6], ctrl[1], stage2[4]);
    mux2X1 m5_2(stage1[5], stage1[7], ctrl[1], stage2[5]);
    mux2X1 m6_2(stage1[6], stage1[0], ctrl[1], stage2[6]);
    mux2X1 m7_2(stage1[7], stage1[1], ctrl[1], stage2[7]);

    // Stage 3: Shift by 1 if ctrl[0] is high
    mux2X1 m0_3(stage2[0], stage2[1], ctrl[0], out[0]);
    mux2X1 m1_3(stage2[1], stage2[2], ctrl[0], out[1]);
    mux2X1 m2_3(stage2[2], stage2[3], ctrl[0], out[2]);
    mux2X1 m3_3(stage2[3], stage2[4], ctrl[0], out[3]);
    mux2X1 m4_3(stage2[4], stage2[5], ctrl[0], out[4]);
    mux2X1 m5_3(stage2[5], stage2[6], ctrl[0], out[5]);
    mux2X1 m6_3(stage2[6], stage2[7], ctrl[0], out[6]);
    mux2X1 m7_3(stage2[7], stage2[0], ctrl[0], out[7]);
endmodule