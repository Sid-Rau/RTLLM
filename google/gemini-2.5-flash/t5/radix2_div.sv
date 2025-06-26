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

reg [16:0] SR; // Shift Register for division
reg [7:0] NEG_DIVISOR; // Negated absolute divisor
reg [3:0] cnt; // Counter for division steps
reg start_cnt; // Flag to start/continue division

wire [7:0] abs_dividend;
wire [7:0] abs_divisor;
wire dividend_neg;
wire divisor_neg;
wire quotient_neg;

assign dividend_neg = sign && dividend[7];
assign divisor_neg = sign && divisor[7];
assign quotient_neg = dividend_neg ^ divisor_neg;

assign abs_dividend = dividend_neg ? (~dividend + 1'b1) : dividend;
assign abs_divisor = divisor_neg ? (~divisor + 1'b1) : divisor;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        SR <= 17'd0;
        NEG_DIVISOR <= 8'd0;
        cnt <= 4'd0;
        start_cnt <= 1'b0;
        res_valid <= 1'b0;
        result <= 16'd0;
    end else begin
        if (opn_valid && !res_valid) begin
            SR <= {abs_dividend, 9'b0}; // Shift dividend left by 1 bit, then append 8 zeros for quotient
            NEG_DIVISOR <= ~abs_divisor + 1'b1;
            cnt <= 4'd1;
            start_cnt <= 1'b1;
            res_valid <= 1'b0;
        end else if (start_cnt) begin
            if (cnt == 8) begin // Division complete
                start_cnt <= 1'b0;
                cnt <= 4'd0;
                res_valid <= 1'b1;

                // Final remainder and quotient adjustment
                if (sign) begin
                    reg [7:0] final_remainder;
                    reg [7:0] final_quotient;

                    final_remainder = SR[16:9];
                    final_quotient = SR[8:1];

                    if (SR[0] == 1'b0) begin // If last subtraction was successful
                        final_remainder = SR[16:9];
                        final_quotient = SR[8:1];
                    end else begin // If last subtraction was unsuccessful
                        final_remainder = SR[16:9] + abs_divisor;
                        final_quotient = SR[8:1];
                    end

                    if (dividend_neg && final_remainder != 8'd0) begin
                        final_remainder = ~final_remainder + 1'b1;
                    end

                    if (quotient_neg && final_quotient != 8'd0) begin
                        final_quotient = ~final_quotient + 1'b1;
                    end
                    result <= {final_remainder, final_quotient};
                end else begin
                    result <= {SR[16:9], SR[8:1]};
                end

            end else begin
                reg [8:0] temp_sub;
                reg carry_out;
                reg [16:0] next_SR;

                // Shift SR left by 1
                next_SR = SR << 1;

                // Perform subtraction
                // SR[16:9] is current partial remainder
                {carry_out, temp_sub} = next_SR[16:9] + NEG_DIVISOR;

                if (carry_out == 1'b1) begin // Subtraction was successful
                    next_SR[16:9] = temp_sub[7:0];
                    next_SR[0] = 1'b1; // Set quotient bit to 1
                end else begin // Subtraction was unsuccessful
                    next_SR[0] = 1'b0; // Set quotient bit to 0
                end
                SR <= next_SR;
                cnt <= cnt + 1'b1;
            end
        end

        if (res_valid && res_ready) begin
            res_valid <= 1'b0; // Clear res_valid once result is consumed
        end
    end
end

endmodule