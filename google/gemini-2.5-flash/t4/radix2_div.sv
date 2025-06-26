module radix2_div (
    input wire clk,
    input wire rst,
    input wire sign,
    input wire [7:0] dividend,
    input wire [7:0] divisor,
    input wire opn_valid,
    input wire res_ready,
    output reg res_valid,
    output reg [15:0] result
);

reg [16:0] SR; // Shift Register for dividend/remainder and quotient
reg [7:0] NEG_DIVISOR; // Negated absolute divisor
reg [3:0] cnt; // Counter for division steps
reg start_cnt; // Flag to start/continue division process
reg [7:0] q_sign; // Quotient sign
reg [7:0] r_sign; // Remainder sign

wire [7:0] abs_dividend;
wire [7:0] abs_divisor;
wire [8:0] sub_result;
wire carry_out;

assign abs_dividend = (sign && dividend[7]) ? (~dividend + 1'b1) : dividend;
assign abs_divisor = (sign && divisor[7]) ? (~divisor + 1'b1) : divisor;

assign sub_result = SR[15:8] + NEG_DIVISOR;
assign carry_out = sub_result[8];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        SR <= 17'b0;
        NEG_DIVISOR <= 8'b0;
        cnt <= 4'b0;
        start_cnt <= 1'b0;
        res_valid <= 1'b0;
        result <= 16'b0;
        q_sign <= 8'b0;
        r_sign <= 8'b0;
    end else begin
        if (opn_valid && !res_valid) begin
            SR <= {abs_dividend, 9'b0}; // Initialize SR with abs_dividend shifted left by 1 (16th bit is 0)
            NEG_DIVISOR <= ~abs_divisor + 1'b1; // Negated absolute divisor
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
            result <= 16'b0;

            if (sign) begin
                if ((dividend[7] ^ divisor[7])) begin // If signs are different, quotient is negative
                    q_sign <= 8'hFF; // All ones for negative
                end else begin
                    q_sign <= 8'h00; // All zeros for positive
                end
                if (dividend[7]) begin // Remainder has same sign as dividend
                    r_sign <= 8'hFF;
                end else begin
                    r_sign <= 8'h00;
                end
            end else begin
                q_sign <= 8'h00;
                r_sign <= 8'h00;
            end
        end else if (start_cnt) begin
            if (cnt == 4'd8) begin // Division complete
                start_cnt <= 1'b0;
                cnt <= 4'b0;
                res_valid <= 1'b1;

                if (sign) begin
                    if (q_sign[7]) begin // Quotient is negative
                        result[7:0] <= ~SR[7:0] + 1'b1;
                    end else begin
                        result[7:0] <= SR[7:0];
                    end

                    if (r_sign[7]) begin // Remainder is negative
                        result[15:8] <= ~SR[15:8] + 1'b1;
                    end else begin
                        result[15:8] <= SR[15:8];
                    end
                end else begin
                    result[15:0] <= SR[15:0];
                end
            end else begin
                cnt <= cnt + 1'b1;
                if (carry_out) begin // SR[15:8] >= abs_divisor
                    SR <= {sub_result[7:0], SR[7:0], 1'b1}; // Shift left, insert 1
                end else begin // SR[15:8] < abs_divisor
                    SR <= {SR[15:0], 1'b0}; // Shift left, insert 0
                end
            end
        end else if (res_valid && res_ready) begin
            res_valid <= 1'b0; // Clear res_valid when result is consumed
        end
    end
end

endmodule