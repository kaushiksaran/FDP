`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 22:14:33
// Design Name: 
// Module Name: Task_r
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

module task_r (
    input clk6p25m,              
    input sw1,                   
    input [12:0] pixel_index,   
    output [15:0] oled_data     
);


    wire valid_pixel = (pixel_index < 6144);
    
    wire [6:0] x = valid_pixel ? (pixel_index % 96) : 0; 
    wire [5:0] y = valid_pixel ? (pixel_index / 96) : 0; 


    reg [17:0] move_counter = 0;
    reg move_tick = 0;
    
    always @(posedge clk6p25m) begin
        if (move_counter >= 246743) begin
            move_counter <= 0;
            move_tick <= 1;
        end else begin
            move_counter <= move_counter + 1;
            move_tick <= 0;
        end
    end

    reg [6:0] blue_x = 0; 
    reg dir = 0;          
    
    always @(posedge clk6p25m) begin

        if (sw1 && move_tick) begin
            if (dir == 0) begin
                if (blue_x >= 75) dir <= 1; 
                else blue_x <= blue_x + 1;
            end else begin
                if (blue_x <= 1) dir <= 0;  
                else blue_x <= blue_x - 1;
            end
        end
    end
    
    wire [5:0] char_y = 17; 

    wire is_blue_5 = (x >= blue_x) && (x < blue_x + 20) && (y >= char_y) && (y < char_y + 30) && (
                     ((x - blue_x < 20) && (y - char_y < 5)) ||                        
                     ((x - blue_x < 5)  && (y - char_y < 15)) ||                       
                     ((x - blue_x < 20) && (y - char_y >= 12) && (y - char_y < 17)) || 
                     ((x - blue_x >= 15)&& (y - char_y >= 12) && (y - char_y < 30)) || 
                     ((x - blue_x < 20) && (y - char_y >= 25))                         
                     );

    wire is_orange_5 = (x >= 38) && (x < 58) && (y >= char_y) && (y < char_y + 30) && (
                     ((x - 38 < 20) && (y - char_y < 5)) ||
                     ((x - 38 < 5)  && (y - char_y < 15)) ||
                     ((x - 38 < 20) && (y - char_y >= 12) && (y - char_y < 17)) ||
                     ((x - 38 >= 15)&& (y - char_y >= 12) && (y - char_y < 30)) ||
                     ((x - 38 < 20) && (y - char_y >= 25))
                     );

    assign oled_data = (!valid_pixel) ? 16'h0000 : 
                       (is_blue_5)    ? 16'h07FF : 
                       (is_orange_5)  ? 16'hFD20 : 
                                        16'h0000;  

endmodule
