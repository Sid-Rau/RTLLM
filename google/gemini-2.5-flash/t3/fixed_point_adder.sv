`timescale 1ns / 1ps

module fixed_point_adder #(
    parameter Q = 8,
    parameter N = 16
) (
    input wire [N-1:0] a,
    input wire [N-1:0] b,
    output reg [N-1:0] c
);

    reg [N-1:0] res;

    always @(*) begin
        if (a[N-1] == b[N-1]) begin // Same signs (both positive or both negative)
            res = a + b;
            c = res;
        end else begin // Different signs (one positive, one negative)
            if (a[N-1] == 1'b0) begin // a is positive, b is negative
                if (a >= (~b + 1'b1)) begin // |a| >= |b|
                    res = a + b;
                    c = res;
                end else begin // |a| < |b|
                    res = b + a;
                    c = res;
                end
            end else begin // a is negative, b is positive
                if (b >= (~a + 1'b1)) begin // |b| >= |a|
                    res = b + a;
                    c = res;
                end else begin // |b| < |a|
                    res = a + b;
                    c = res;
                end
            end
        end
    end

endmodule