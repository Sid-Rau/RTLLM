module calendar(
    input CLK,
    input RST,
    output reg [5:0] Hours,
    output reg [5:0] Mins,
    output reg [5:0] Secs
);
    
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Secs <= 6'b000000;
        end else begin
            if (Secs == 59) begin
                Secs <= 6'b000000;
            end else begin
                Secs <= Secs + 1;
            end
        end
    end
    
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Mins <= 6'b000000;
        end else begin
            if (Secs == 59) begin
                if (Mins == 59) begin
                    Mins <= 6'b000000;
                end else begin
                    Mins <= Mins + 1;
                end
            end
        end
    end
    
    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            Hours <= 6'b000000;
        end else begin
            if (Secs == 59 && Mins == 59) begin
                if (Hours == 23) begin
                    Hours <= 6'b000000;
                end else begin
                    Hours <= Hours + 1;
                end
            end
        end
    end
    
endmodule