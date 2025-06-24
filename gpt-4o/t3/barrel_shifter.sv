module mux2X1(input wire [7:0] a, input wire [7:0] b, input wire sel, output wire [7:0] y);
    assign y = sel ? b : a;
endmodule

module barrel_shifter(input wire [7:0] in, input wire [2:0] ctrl, output wire [7:0] out);
    wire [7:0] stage1, stage2;

    // Shift by 4 positions if ctrl[2] is high
    mux2X1 mux4(
        .a(in), 
        .b({in[3:0], in[7:4]}), 
        .sel(ctrl[2]), 
        .y(stage1)
    );

    // Shift by 2 positions if ctrl[1] is high
    mux2X1 mux2(
        .a(stage1), 
        .b({stage1[1:0], stage1[7:2]}), 
        .sel(ctrl[1]), 
        .y(stage2)
    );

    // Shift by 1 position if ctrl[0] is high
    mux2X1 mux1(
        .a(stage2), 
        .b({stage2[0], stage2[7:1]}), 
        .sel(ctrl[0]), 
        .y(out)
    );
endmodule