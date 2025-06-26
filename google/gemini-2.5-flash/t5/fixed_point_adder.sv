module fixed_point_adder #(
  parameter Q = 8,
  parameter N = 16
) (
  input wire [N-1:0] a,
  input wire [N-1:0] b,
  output wire [N-1:0] c
);

reg [N-1:0] res;

assign c = res;

always @(*) begin
  if (a[N-1] == b[N-1]) begin // Same signs (both positive or both negative)
    res = a + b;
  end else begin // Different signs (one positive, one negative)
    if (a[N-1] == 0) begin // a is positive, b is negative
      if (a >= (~b + 1'b1)) begin // |a| >= |b|
        res = a + b; // Equivalent to a - |b|
      end else begin // |a| < |b|
        res = b + a; // Equivalent to b - |a|
      end
    end else begin // a is negative, b is positive
      if (b >= (~a + 1'b1)) begin // |b| >= |a|
        res = b + a; // Equivalent to b - |a|
      end else begin // |b| < |a|
        res = a + b; // Equivalent to a - |b|
      end
    end
  end
end

endmodule