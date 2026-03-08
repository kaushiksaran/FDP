`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: Vanchinathan Sindhu Yazhini (Subtask P)
//  STUDENT B NAME:Sidhaarth Satish (Subtask Q)
//  STUDENT C NAME: Lim Keon Jin
//  STUDENT D NAME: Kaushik Saravanan (Subtask S)
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input basys3_clock, input btnD,input btnU,input SW1,SW12, SW13, SW14, SW15, output[7:0] JA,output [7:0] seg,output [3:0] an, input btnL, input btnR);
     
    wire clk6p25m;
    wire [12:0] pixel_index;
    wire frame_begin;
    wire [15:0] oled_data_P;
    wire [15:0] oled_data_Q;
    wire [15:0] oled_data_R;
    wire [15:0] oled_data_S;
    wire [15:0] oled_data; 
    wire btnU_clean;
    reg [7:0] seg_reg;
    reg [3:0] an_reg;
    
    debounce db_up (.clk(clk6p25m), .btn_in(btnU),  .btn_out(btnU_clean));
    //6.25 MHz clock
    custom_clock clock(.clock(basys3_clock), .m_val(7), .custom_clock(clk6p25m));
    //Oled Display
    Oled_Display oled(.clk(clk6p25m), .pixel_data(oled_data), .reset(btnD), .frame_begin(frame_begin),
    .cs(JA[0]), .sdin(JA[1]), .sclk(JA[3]), .d_cn(JA[4]),
    .resn(JA[5]), .vccen(JA[6]), .pmoden(JA[7]), .pixel_index(pixel_index));
    
    //Subtask A
    task_p task_p(.clk6p25m(clk6p25m), .frame_begin(frame_begin), .btnU(btnU_clean),
        .pixel_index(pixel_index), .oled_data(oled_data_P));
    //Subtask B
     task_q task_q (.clk6p25m(clk6p25m), .btnD(btnD),.pixel_index(pixel_index),.oled_data(oled_data_Q));
    //Subtask C
    task_r task_r(.clk6p25m(clk6p25m),.sw1(SW1),.pixel_index(pixel_index),.oled_data(oled_data_R));
    //Subtask D
    task_s task_s(.clk6p25m(clk6p25m), .frame_begin(frame_begin), .btnL(btnL), .btnR(btnR),
    .pixel_index(pixel_index), .oled_data(oled_data_S));
    
    assign oled_data =  SW15 ? oled_data_S  :
                        SW14 ? oled_data_R  :
                        SW13 ? oled_data_Q  :
                        SW12 ? oled_data_P  : 16'h0000;
reg [16:0] refresh_counter;
       always @(posedge clk6p25m)
           refresh_counter <= refresh_counter + 1;
       
       wire [1:0] digit_select = refresh_counter[16:15];
       
       always @(*) begin
           case (digit_select)
               2'b00: begin
                   an_reg  = 4'b1110;        // rightmost digit
                   seg_reg = 8'b10010010;    // '5'
               end
               2'b01: begin
                   an_reg  = 4'b1101;        // second digit
                   seg_reg = 8'b11000000;    // '0'
               end
               2'b10: begin
                   an_reg  = 4'b1011;        // third digit
                   seg_reg = 8'b11111001;    // '1'
               end
               2'b11: begin
                   an_reg  = 4'b0111;        // leftmost digit (was 1111 = OFF, now 0111 = ON)
                   seg_reg = 8'b10010010;    // '5'
               end
           endcase
       end
       
       assign seg = seg_reg;
       assign an  = an_reg;

endmodule