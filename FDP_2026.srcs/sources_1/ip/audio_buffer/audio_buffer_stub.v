// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Fri Apr  3 12:54:39 2026
// Host        : Jins_Fake_Mac running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {c:/Users/limke/Desktop/2026
//               project/FDP/FDP_2026.srcs/sources_1/ip/audio_buffer/audio_buffer_stub.v}
// Design      : audio_buffer
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2018.2" *)
module audio_buffer(clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, 
  dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[8:0],dina[31:0],douta[31:0],clkb,enb,web[0:0],addrb[8:0],dinb[31:0],doutb[31:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [8:0]addra;
  input [31:0]dina;
  output [31:0]douta;
  input clkb;
  input enb;
  input [0:0]web;
  input [8:0]addrb;
  input [31:0]dinb;
  output [31:0]doutb;
endmodule
