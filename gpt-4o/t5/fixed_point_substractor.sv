module fixed_point_subtractor #(parameter Q = 8, parameter N = 16)(
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output reg [N-1:0] c
);
    reg [N-1:0] res;
    reg signed [N-1:0] a_signed, b_signed, res_signed;

    always @(*) begin
        a_signed = a;
        b_signed = b;
        if (a[N-1] == b[N-1]) begin
            res_signed = a_signed - b_signed;
        end else begin
            res_signed = a_signed + b_signed;
        end
        res = res_signed;
        if (res == 0) begin
            c = {1'b0, res[N-2:0]};
        end else begin
            c = res;
        end
    end
endmodule