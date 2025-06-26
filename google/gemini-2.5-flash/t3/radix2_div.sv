module radix2_div (
    input clk,
    input rst,
    input sign,
    input [7:0] dividend,
    input [7:0] divisor,
    input opn_valid,
    input res_ready,
    output reg res_valid,
    output reg [15:0] result
);

reg [16:0] SR; // Shift Register for division, 1 bit for sign, 8 for remainder, 8 for quotient
reg [7:0] NEG_DIVISOR; // Negated absolute value of divisor
reg [3:0] cnt; // Counter for division steps (0 to 8)
reg start_cnt; // Flag to start/continue division process
reg dividend_sign; // Sign of the dividend
reg divisor_sign; // Sign of the divisor
reg result_sign; // Sign of the final quotient

wire [8:0] subtract_result;
wire carry_out;

assign subtract_result = SR[16:8] + NEG_DIVISOR;
assign carry_out = subtract_result[8]; // MSB of subtract_result is carry_out

always @(posedge clk or posedge rst) begin
    if (rst) begin
        SR <= 17'b0;
        NEG_DIVISOR <= 8'b0;
        cnt <= 4'b0;
        start_cnt <= 1'b0;
        res_valid <= 1'b0;
        result <= 16'b0;
        dividend_sign <= 1'b0;
        divisor_sign <= 1'b0;
        result_sign <= 1'b0;
    end else begin
        if (opn_valid && !res_valid) begin
            reg [7:0] abs_dividend;
            reg [7:0] abs_divisor;

            if (sign) begin // Signed operation
                dividend_sign = dividend[7];
                divisor_sign = divisor[7];
                result_sign = dividend_sign ^ divisor_sign;

                abs_dividend = dividend_sign ? (~dividend + 1'b1) : dividend;
                abs_divisor = divisor_sign ? (~divisor + 1'b1) : divisor;
            end else begin // Unsigned operation
                dividend_sign = 1'b0;
                divisor_sign = 1'b0;
                result_sign = 1'b0;
                abs_dividend = dividend;
                abs_divisor = divisor;
            end

            SR <= {1'b0, abs_dividend, 8'b0}; // Initialize SR with 0, abs(dividend), and 8 zeros for quotient
            NEG_DIVISOR <= (~abs_divisor + 1'b1); // Negate absolute value of divisor
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            if (cnt == 4'd8) begin // Division complete
                start_cnt <= 1'b0;
                cnt <= 4'b0;
                res_valid <= 1'b1;

                reg [7:0] final_remainder;
                reg [7:0] final_quotient;

                if (carry_out) begin // SR[16:8] - NEG_DIVISOR was positive
                    final_remainder = subtract_result[7:0];
                    final_quotient = SR[7:0] << 1 | 1'b1;
                end else begin // SR[16:8] - NEG_DIVISOR was negative
                    final_remainder = SR[15:8];
                    final_quotient = SR[7:0] << 1;
                end

                if (sign) begin
                    // Adjust remainder sign
                    if (dividend_sign) begin
                        final_remainder = (~final_remainder + 1'b1);
                    end
                    // Adjust quotient sign
                    if (result_sign) begin
                        final_quotient = (~final_quotient + 1'b1);
                    end
                end
                result <= {final_remainder, final_quotient};
            end else begin // Continue division
                cnt <= cnt + 1'b1;
                if (carry_out) begin // Remainder >= Divisor, so subtract and set quotient bit to 1
                    SR <= {subtract_result[7:0], SR[7:0], 1'b1};
                end else begin // Remainder < Divisor, so don't subtract and set quotient bit to 0
                    SR <= {SR[15:8], SR[7:0], 1'b0};
                end
            end
        end else if (res_valid && res_ready) begin
            res_valid <= 1'b0; // Consume result
        end
    end
end

endmodule