module fixed_point_subtractor #(
    parameter Q = 8,
    parameter N = 16
) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    output wire [N-1:0] c
);

reg [N-1:0] res;

assign c = res;

function [N-1:0] twos_complement;
    input [N-1:0] val;
    begin
        twos_complement = ~val + 1;
    end
endfunction

always @(*) begin
    reg signed [N-1:0] signed_a;
    reg signed [N-1:0] signed_b;
    reg signed [N-1:0] signed_result;

    signed_a = a;
    signed_b = b;

    signed_result = signed_a - signed_b;

    if (signed_result == 0) begin
        res = {1'b0, {(N-1){1'b0}}}; // Explicitly set sign bit to 0 for zero
    end else begin
        res = signed_result;
    end
end

endmodule