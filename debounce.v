module debounce(
    input clk,
    input btn_in,
    output reg btn_out
);

reg [1:0] sync;     
reg [19:0] counter;    
reg btn_stable;       

// Stage 1: Synchronize 
always @(posedge clk) begin
    sync <= {sync[0], btn_in};  
end

// Stage 2: Counter
always @(posedge clk) begin
    if (sync[1] != btn_stable) begin
        counter <= counter + 1;         
        if (counter == 20'hFFFFF) begin 
            btn_stable <= sync[1];
            btn_out    <= sync[1];
        end
    end else begin
        counter <= 0;
    end
end

endmodule

