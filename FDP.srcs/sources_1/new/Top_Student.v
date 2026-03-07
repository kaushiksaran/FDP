`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME: Kaushik Saravanan (Subtask S)
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input basys3_clock, input btnD, input SW4, output[7:0] JA, input btnL, input btnR);
     
    wire clk6p25m;
    wire [12:0] pixel_index;
    wire frame_begin;
    wire [15:0] oled_data;  
        
    //6.25 MHz clock
    custom_clock clock(.clock(basys3_clock), .m_val(7), .custom_clock(clk6p25m));
    //Oled Display
    Oled_Display oled(.clk(clk6p25m), .pixel_data(oled_data), .reset(btnD), .frame_begin(frame_begin),
    .cs(JA[0]), .sdin(JA[1]), .sclk(JA[3]), .d_cn(JA[4]),
    .resn(JA[5]), .vccen(JA[6]), .pmoden(JA[7]), .pixel_index(pixel_index));
    //Subtask C
    Task_S task_s(.clk6p25m(clk6p25m), .frame_begin(frame_begin), .btnL(btnL), .btnR(btnR),
    .pixel_index(pixel_index), .oled_data(oled_data));
    

endmodule