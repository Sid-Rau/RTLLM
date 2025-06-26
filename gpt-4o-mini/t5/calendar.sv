module calendar (
    input wire CLK,
    input wire RST,
    output reg [5:0] Hours,
    output reg [5:0] Mins,
    output reg [5:0] Secs
);
    
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Secs <= 6'b000000;
        end else if (Secs == 6'b111011) begin
            Secs <= 6'b000000;
        end else begin
            Secs <= Secs + 1;
        end
    end

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Mins <= 6'b000000;
        end else if (Secs == 6'b111011) begin
            if (Mins == 6'b111011) begin
                Mins <= 6'b000000;
            end else begin
                Mins <= Mins + 1;
            end
        end
    end

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Hours <= 6'b000000;
        end else if (Secs == 6'b111011 && Mins == 6'b111011) begin
            if (Hours == 6'b010111) begin
                Hours <= 6'b000000;
            end else begin
                Hours <= Hours + 1;
            end
        end
    end
endmodule