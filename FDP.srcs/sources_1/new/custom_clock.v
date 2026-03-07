`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.03.2026 16:23:47
// Design Name: 
// Module Name: custom_clock
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


module custom_clock (input clock, input[3:0] m_val, output reg custom_clock = 0);

    reg[3:0] COUNT = 0;
    
    always @ (posedge clock) 
    begin   
        COUNT <= (COUNT == m_val) ? 0 : (COUNT + 1);
        custom_clock <= (COUNT == m_val) ? ~custom_clock : custom_clock ;              
    end
    
endmodule
