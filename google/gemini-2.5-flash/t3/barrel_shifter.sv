module mux2X1 (
    input a,
    input b,
    input sel,
    output out
);

assign out = sel ? b : a;

endmodule

module barrel_shifter (
    input [7:0] in,
    input [2:0] ctrl,
    output [7:0] out
);

wire [7:0] s1_out;
wire [7:0] s2_out;

genvar i;

generate
    for (i = 0; i < 8; i = i + 1) begin : stage1_mux
        mux2X1 m1 (
            .a   (in[i]),
            .b   (in[(i + 4) % 8]),
            .sel (ctrl[2]),
            .out (s1_out[i])
        );
    end
endgenerate

generate
    for (i = 0; i < 8; i = i + 1) begin : stage2_mux
        mux2X1 m2 (
            .a   (s1_out[i]),
            .b   (s1_out[(i + 2) % 8]),
            .sel (ctrl[1]),
            .out (s2_out[i])
        );
    end
endgenerate

generate
    for (i = 0; i < 8; i = i + 1) begin : stage3_mux
        mux2X1 m3 (
            .a   (s2_out[i]),
            .b   (s2_out[(i + 1) % 8]),
            .sel (ctrl[0]),
            .out (out[i])
        );
    end
endgenerate

endmodule