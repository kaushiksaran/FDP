## =========================================================================
## Basys 3 Master Constraints for Speaker ID / FFT Project
## =========================================================================

## -------------------------------------------------------------------------
## 1. System Clock (100 MHz)
## -------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## -------------------------------------------------------------------------
## 2. Buttons
## -------------------------------------------------------------------------
# Center Button used as active-high global reset
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports reset_btn]

## -------------------------------------------------------------------------
## 3. LEDs (16-bit Magnitude Output)
## -------------------------------------------------------------------------
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {led[0]}]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports {led[1]}]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports {led[2]}]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports {led[3]}]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports {led[4]}]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports {led[5]}]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports {led[6]}]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports {led[7]}]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports {led[8]}]
set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports {led[9]}]
set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 } [get_ports {led[10]}]
set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports {led[11]}]
set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 } [get_ports {led[12]}]
set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [get_ports {led[13]}]
set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 } [get_ports {led[14]}]
set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 } [get_ports {led[15]}]

## -------------------------------------------------------------------------
## 4. Pmod Header JA (Microphone SPI)
## -------------------------------------------------------------------------
# JA Pin 1 (CS)
set_property -dict { PACKAGE_PIN J1   IOSTANDARD LVCMOS33 } [get_ports cs]
# JA Pin 3 (MISO)
set_property -dict { PACKAGE_PIN J2   IOSTANDARD LVCMOS33 } [get_ports miso]
# JA Pin 4 (SCLK)
set_property -dict { PACKAGE_PIN G2   IOSTANDARD LVCMOS33 } [get_ports sclk]

## -------------------------------------------------------------------------
## 5. Configuration & Voltage Settings
## -------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]