`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2026 22:22:00
// Design Name: 
// Module Name: Task_S
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


module task_s(
        input clk6p25m, frame_begin, btnL, btnR,
        input [12:0] pixel_index,
        output reg [15:0] oled_data
    );
    
    wire[6:0] col;
    wire[5:0] row;
    reg moving_left = 0;
    reg moving_right = 0;
    reg [6:0] cx;
    initial cx = 47;
    reg[1:0] frame_skip = 0;
    localparam red = 16'hF800;
    localparam green = 16'h07E0;
    localparam white = 16'hFFFF;
    localparam circle_rad_sq = 400;
    
     assign col = pixel_index % 96;
     assign row = pixel_index / 96;
     
     always@(*) begin
         oled_data = 16'h0000;
         // circle with dynamic cx
         if (row >= 21 && row <= 41 && col + 10 >= cx && col <= cx + 10)
             if ((2*row+1-62)*(2*row+1-62) + (2*col+1-2*cx)*(2*col+1-2*cx) < circle_rad_sq)
                 oled_data = red;
         // white vertical strip
         if ((col >= 20 && col <= 24) && (row >= 7 && row <= 56))
             oled_data = white;
         // top horizontal - 3px thick
         if (col >= 6 && col <= 13 && (row >= 22 && row <= 24))
             oled_data = green;
         // middle horizontal - 3px thick
         if (col >= 6 && col <= 13 && (row >= 29 && row <= 31))
             oled_data = green;
         // bottom horizontal - 3px thick
         if (col >= 6 && col <= 13 && (row >= 35 && row <= 37))
             oled_data = green;
         // left vertical - 3px thick
         if (col >= 6 && col <= 8 && (row >= 22 && row <= 37))
             oled_data = green;
         // right vertical bottom half only - 3px thick
         if (col >= 11 && col <= 13 && (row >= 31 && row <= 37))
             oled_data = green;
     end
     
     always @(posedge clk6p25m) begin
         if (btnL) begin
             moving_left <= 1;
             moving_right <= 0;
         end else if (btnR) begin
             moving_right <= 1;
             moving_left <= 0;
         end
         if (frame_begin) begin
            //logic for 40 fps movement
             frame_skip <= (frame_skip == 2) ? 0 : frame_skip + 1;
             if (frame_skip != 2) begin
                 if (moving_left && cx > 36)
                     cx <= cx - 1;
                 if (moving_right && cx < 85)
                     cx <= cx + 1;
             end
         end
     end

endmodule
