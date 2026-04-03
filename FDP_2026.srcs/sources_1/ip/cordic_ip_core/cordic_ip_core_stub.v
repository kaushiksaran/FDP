// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Fri Apr  3 16:33:55 2026
// Host        : Jins_Fake_Mac running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {c:/Users/limke/Desktop/2026
//               project/FDP/FDP_2026.srcs/sources_1/ip/cordic_ip_core/cordic_ip_core_stub.v}
// Design      : cordic_ip_core
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "cordic_v6_0_14,Vivado 2018.2" *)
module cordic_ip_core(aclk, aresetn, s_axis_cartesian_tvalid, 
  s_axis_cartesian_tready, s_axis_cartesian_tlast, s_axis_cartesian_tdata, 
  m_axis_dout_tvalid, m_axis_dout_tready, m_axis_dout_tlast, m_axis_dout_tdata)
/* synthesis syn_black_box black_box_pad_pin="aclk,aresetn,s_axis_cartesian_tvalid,s_axis_cartesian_tready,s_axis_cartesian_tlast,s_axis_cartesian_tdata[31:0],m_axis_dout_tvalid,m_axis_dout_tready,m_axis_dout_tlast,m_axis_dout_tdata[31:0]" */;
  input aclk;
  input aresetn;
  input s_axis_cartesian_tvalid;
  output s_axis_cartesian_tready;
  input s_axis_cartesian_tlast;
  input [31:0]s_axis_cartesian_tdata;
  output m_axis_dout_tvalid;
  input m_axis_dout_tready;
  output m_axis_dout_tlast;
  output [31:0]m_axis_dout_tdata;
endmodule
