module multi_pipe_8bit (
    input wire clk,
    input wire rst_n,
    input wire mul_en_in,
    input wire [7:0] mul_a,
    input wire [7:0] mul_b,
    output reg mul_en_out,
    output reg [15:0] mul_out
);
    reg mul_en_out_reg;
    reg [7:0] mul_a_reg;
    reg [7:0] mul_b_reg;
    reg [15:0] partial_products[7:0];
    reg [15:0] sum[3:0];
    reg [15:0] mul_out_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mul_en_out_reg <= 1'b0;
            mul_a_reg <= 8'b0;
            mul_b_reg <= 8'b0;
            mul_out_reg <= 16'b0;
            mul_out <= 16'b0;
            mul_en_out <= 1'b0;
        end else begin
            mul_en_out_reg <= mul_en_in;
            if (mul_en_in) begin
                mul_a_reg <= mul_a;
                mul_b_reg <= mul_b;
            end
            mul_en_out <= mul_en_out_reg;
        end
    end

    always @(posedge clk) begin
        if (mul_en_out_reg) begin
            partial_products[0] <= mul_a_reg & {8{mul_b_reg[0]}};
            partial_products[1] <= mul_a_reg & {8{mul_b_reg[1]}};
            partial_products[2] <= mul_a_reg & {8{mul_b_reg[2]}};
            partial_products[3] <= mul_a_reg & {8{mul_b_reg[3]}};
            partial_products[4] <= mul_a_reg & {8{mul_b_reg[4]}};
            partial_products[5] <= mul_a_reg & {8{mul_b_reg[5]}};
            partial_products[6] <= mul_a_reg & {8{mul_b_reg[6]}};
            partial_products[7] <= mul_a_reg & {8{mul_b_reg[7]}};
        end
    end

    always @(posedge clk) begin
        if (mul_en_out_reg) begin
            sum[0] <= partial_products[0];
            sum[1] <= partial_products[1] << 1;
            sum[2] <= partial_products[2] << 2;
            sum[3] <= partial_products[3] << 3;
            mul_out_reg <= sum[0] + sum[1] + sum[2] + sum[3];
            mul_out_reg <= mul_out_reg + partial_products[4] + partial_products[5] + partial_products[6] + partial_products[7];
        end
    end

    always @(posedge clk) begin
        if (mul_en_out_reg) begin
            mul_out <= mul_out_reg;
        end else begin
            mul_out <= 16'b0;
        end
    end
endmodule