module radix2_div (
    input clk,
    input rst,
    input sign,
    input [7:0] dividend,
    input [7:0] divisor,
    input opn_valid,
    output reg res_valid,
    output reg [15:0] result
);

reg [7:0] dividend_reg;
reg [7:0] divisor_reg;
reg [15:0] SR;
reg [7:0] NEG_DIVISOR;
reg [3:0] cnt;
reg start_cnt;
wire [8:0] sub_result;
wire carry_out;

assign sub_result = SR[15:8] + NEG_DIVISOR;
assign carry_out = ~sub_result[8];

always @(posedge clk or posedge rst) begin
    if (rst) begin
        res_valid <= 0;
        result <= 0;
        SR <= 0;
        NEG_DIVISOR <= 0;
        cnt <= 0;
        start_cnt <= 0;
        dividend_reg <= 0;
        divisor_reg <= 0;
    end else begin
        if (opn_valid && !res_valid) begin
            dividend_reg <= (sign && dividend[7]) ? -dividend : dividend;
            divisor_reg <= (sign && divisor[7]) ? -divisor : divisor;
            SR <= {(sign && dividend[7]) ? -dividend : dividend, 8'b0};
            NEG_DIVISOR <= -(sign && divisor[7]) ? -divisor : divisor;
            cnt <= 1;
            start_cnt <= 1;
            res_valid <= 0;
        end

        if (start_cnt) begin
            if (cnt[3]) begin
                start_cnt <= 0;
                cnt <= 0;
                res_valid <= 1;
                if (sign) begin
                    if (dividend[7] ^ divisor[7]) begin
                        result[7:0] <= -SR[7:0];
                    end else begin
                        result[7:0] <= SR[7:0];
                    end
                    if (dividend[7]) begin
                        result[15:8] <= -SR[15:8];
                    end else begin
                        result[15:8] <= SR[15:8];
                    end
                end else begin
                    result <= SR;
                end
            end else begin
                cnt <= cnt + 1;
                SR <= {SR[14:0], carry_out};
                if (carry_out) begin
                    SR[15:8] <= sub_result[7:0];
                end
            end
        end

        if (res_valid && opn_valid) begin
            res_valid <= 0;
        end
    end
end

endmodule