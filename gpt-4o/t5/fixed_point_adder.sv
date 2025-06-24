module fixed_point_adder #(parameter Q = 8, parameter N = 16)(
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output wire [N-1:0] c
);

    wire signed [N-1:0] a_ext = a;
    wire signed [N-1:0] b_ext = b;
    reg signed [N-1:0] res;

    always @(*) begin
        if (a[N-1] == b[N-1]) begin
            res = a_ext + b_ext;
        end else begin
            if (a_ext > b_ext) begin
                res = a_ext - b_ext;
            end else begin
                res = b_ext - a_ext;
            end
        end
    end

    assign c = res;

endmodule