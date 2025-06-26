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

    reg [7:0] abs_dividend;
    reg [7:0] abs_divisor;
    reg [16:0] SR;
    reg [7:0] NEG_DIVISOR;
    reg [3:0] cnt;
    reg start_cnt;
    wire carry_out;
    wire [8:0] sub_result;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            res_valid <= 0;
            result <= 0;
            SR <= 0;
            cnt <= 0;
            start_cnt <= 0;
            abs_dividend <= 0;
            abs_divisor <= 0;
            NEG_DIVISOR <= 0;
        end else begin
            if (opn_valid && !res_valid) begin
                abs_dividend <= (sign && dividend[7]) ? -dividend : dividend;
                abs_divisor <= (sign && divisor[7]) ? -divisor : divisor;
                SR <= {(sign && dividend[7]) ? -dividend : dividend, 1'b0};
                NEG_DIVISOR <= -((sign && divisor[7]) ? -divisor : divisor);
                cnt <= 1;
                start_cnt <= 1;
                res_valid <= 0;
            end

            if (start_cnt) begin
                if (cnt[3]) begin
                    SR <= {SR[16:9], SR[7:0]};
                    result[15:8] <= (sign && (dividend[7] ^ divisor[7])) ? -SR[16:9] : SR[16:9];
                    result[7:0] <= (sign && (dividend[7] ^ divisor[7])) ? -SR[7:0] : SR[7:0];
                    res_valid <= 1;
                    start_cnt <= 0;
                end else begin
                    sub_result = SR[16:8] + NEG_DIVISOR;
                    carry_out = ~sub_result[8];
                    SR <= {sub_result[7:0], SR[7:1], carry_out};
                    cnt <= cnt + 1;
                end
            end

            if (res_valid && opn_valid) begin
                res_valid <= 0;
            end
        end
    end

endmodule