`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 18:48:18
// Design Name: 
// Module Name: task_p
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
module task_p(
    input clk6p25m, frame_begin, btnU,
    input [12:0] pixel_index,
    output reg [15:0] oled_data
);
    wire [6:0] col;
    wire [5:0] row;
    localparam red    = 16'hF800;
    localparam green  = 16'h07E0;
    localparam white  = 16'hFFFF;
    localparam white_cx = 15;
    localparam white_cy = 12;
    assign col = pixel_index % 96;
    assign row = pixel_index / 96;
    
     reg [20:0] press_lock = 0;
       reg [20:0] rel_lock   = 0;
       reg        btn_locked = 0;
       reg        display_on = 1'b1;
   
       always @(posedge clk6p25m) begin
           if (press_lock > 0) press_lock <= press_lock - 1;
           if (rel_lock   > 0) rel_lock   <= rel_lock   - 1;
   
           // Press: toggle display, start lockout
           if (btnU == 1'b1 && !btn_locked && press_lock == 0) begin
               display_on <= ~display_on;
               press_lock <= 21'd1_250_000;
               btn_locked <= 1;
           end
   
           // Release: just unlock, don't toggle
           if (btnU == 1'b0 && btn_locked && rel_lock == 0) begin
               rel_lock   <= 21'd1_250_000;
               btn_locked <= 0;
           end
       end
    // --- Pixel drawing ---
    always @(*) begin
        oled_data = 16'h0000;  // default: black
        if (display_on) begin
            // White circle
            if (row >= 6 && row <= 18 && col >= 9 && col <= 21)
                if ((2*row+1 - 2*white_cy)*(2*row+1 - 2*white_cy) +
                    (2*col+1 - 2*white_cx)*(2*col+1 - 2*white_cx) < 144)
                    oled_data = white;
            // RED letter (4 shape)
            // left vertical
            if (col >= 30 && col <= 32 && row >= 24 && row <= 31)
                         oled_data = red;
            // right full vertical
            if (col >= 35 && col <= 37 && row >= 24 && row <= 39)
                 oled_data = red;
             // middle horizontal
            if (col >= 30 && col <= 37 && row >= 29 && row <= 31)
                 oled_data = red;
            // GREEN letter (S shape)
            // top horizontal
            if (col >= 55 && col <= 62 && row >= 24 && row <= 26)
                oled_data = green;
            // middle horizontal
            if (col >= 55 && col <= 62 && row >= 29 && row <= 31)
                oled_data = green;
            // bottom horizontal
            if (col >= 55 && col <= 62 && row >= 37 && row <= 39)
                oled_data = green;
            // left top vertical
            if (col >= 55 && col <= 57 && row >= 24 && row <= 31)
                oled_data = green;
            // right bottom vertical
            if (col >= 60 && col <= 62 && row >= 31 && row <= 39)
                oled_data = green;
        end
    end
endmodule