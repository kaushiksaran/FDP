`timescale 1ns / 1ps

module top(
    input  wire        clk,         // 100MHz Basys 3 system clock
    input  wire        reset_btn,   // Active-high button for system reset
    input  wire        miso,        // JA Pin 3 (Pmod MIC3 MISO)
    output wire        sclk,        // JA Pin 4 (Pmod MIC3 SCLK)
    output wire        cs,          // JA Pin 1 (Pmod MIC3 CS)
    output wire [15:0] led          // LEDs for VU Meter display
);

    // ==========================================
    // 0. Global Reset Logic
    // ==========================================
    // Vivado AXI IPs use active-low reset (aresetn).
    wire aresetn = ~reset_btn;

    // ==========================================
    // 1. Interconnect Wires
    // ==========================================
    wire [11:0] mic_data;
    wire        mic_valid;

    wire [15:0] windowed_data;
    wire        windowed_valid;
    wire        frame_done_pulse;

    wire [31:0] complex_data;
    wire        complex_valid;
    wire        complex_ready;
    wire        complex_last;

    wire [31:0] cordic_out_data; 
    wire        magnitude_valid;
    wire        magnitude_last;

    // ==========================================
    // 2. Microphone SPI Master
    // ==========================================
    mic_spi_interface mic_inst (
        .basys3_clk  (clk),
        .miso        (miso),
        .cs          (cs),
        .sclk        (sclk),
        .sample_data (mic_data),
        .sample_valid(mic_valid)
    );

    // ==========================================
    // 3. Pre-emphasis and Hamming Window
    // ==========================================
    preemphasis_hamming front_end_inst (
        .basys3_clk     (clk),
        .sample_data    (mic_data),
        .sample_valid   (mic_valid),
        .windowed_sample(windowed_data),
        .sample_index   (),                 
        .frame_start    (),                 
        .frame_done     (frame_done_pulse), 
        .out_valid      (windowed_valid)    
    );

    // ==========================================
    // THE X-SHIELD (Hardware-Safe)
    // ==========================================
    wire [31:0] safe_fft_tdata  = (windowed_valid == 1'b1) ? {16'h0000, windowed_data} : 32'd0;
    wire        safe_fft_tlast  = (windowed_valid == 1'b1) ? frame_done_pulse : 1'b0;
    wire        safe_fft_tvalid = (windowed_valid == 1'b1);

    wire [31:0] safe_cordic_tdata  = (complex_valid == 1'b1) ? complex_data : 32'd0;
    wire        safe_cordic_tvalid = (complex_valid == 1'b1);

    // ==========================================
    // FFT CONFIGURATION HANDSHAKE (1-SHOT)
    // ==========================================
    reg  config_valid = 1'b1; 
    wire config_ready;

    always @(posedge clk) begin
        if (!aresetn) begin
            config_valid <= 1'b1; 
        end else if (config_valid && config_ready) begin
            config_valid <= 1'b0; 
        end
    end

    // ==========================================
    // 4. Radix-2 Burst I/O FFT IP Core
    // ==========================================
    fft_ip_core fft_inst (
        .aclk                 (clk),
        .aresetn              (aresetn),
        
        // Configuration Channel
        .s_axis_config_tdata  (16'd1), // Forward FFT
        .s_axis_config_tvalid (config_valid), 
        .s_axis_config_tready (config_ready),
        
        // Data Channel
        .s_axis_data_tdata    (safe_fft_tdata), 
        .s_axis_data_tvalid   (safe_fft_tvalid),
        .s_axis_data_tready   (),                 
        .s_axis_data_tlast    (safe_fft_tlast),
        
        // Output Channel
        .m_axis_data_tdata    (complex_data),     
        .m_axis_data_tvalid   (complex_valid),
        .m_axis_data_tready   (complex_ready),
        .m_axis_data_tlast    (complex_last),
        
        // Status Channel Tie-Off (Prevents implementation crash)
        .m_axis_status_tready (1'b1)
    );

    // ==========================================
    // 5. CORDIC IP Core (Cartesian to Polar)
    // ==========================================
    cordic_ip_core mag_inst (
        .aclk                   (clk),
        .aresetn                (aresetn),
        
        // Input from FFT
        .s_axis_cartesian_tdata (safe_cordic_tdata),
        .s_axis_cartesian_tvalid(safe_cordic_tvalid),
        .s_axis_cartesian_tready(complex_ready), 
        .s_axis_cartesian_tlast (complex_last),
        
        // Output Magnitude
        .m_axis_dout_tdata      (cordic_out_data),
        .m_axis_dout_tvalid     (magnitude_valid),
        .m_axis_dout_tlast      (magnitude_last),
        .m_axis_dout_tready     (1'b1) 
    );

    // ==========================================
    // 6. Debug / LED Output (VU Meter with DC Filter)
    // ==========================================
    reg [8:0]  bin_cnt = 9'd0;
    reg [15:0] max_mag = 16'd0;
    reg [15:0] vu_meter = 16'd0;

    always @(posedge clk) begin
        if (!aresetn) begin
            bin_cnt  <= 9'd0;
            max_mag  <= 16'd0;
            vu_meter <= 16'd0;
        end else if (magnitude_valid == 1'b1) begin
            
            // DC FILTER: Ignore the first 5 bins (DC offset and low-frequency electrical hum)
            // This prevents the LEDs from being pinned high in a quiet room.
            if (bin_cnt > 9'd5) begin 
                if (cordic_out_data[15:0] > max_mag) begin
                    max_mag <= cordic_out_data[15:0];
                end
            end
            
            // At end of the 512-bin frame (TLAST)
            if (magnitude_last == 1'b1) begin
                // Thresholds: Higher numbers = less sensitive meter.
                vu_meter[0]  <= (max_mag > 16'd50);
                vu_meter[1]  <= (max_mag > 16'd100);
                vu_meter[2]  <= (max_mag > 16'd200);
                vu_meter[3]  <= (max_mag > 16'd400);
                vu_meter[4]  <= (max_mag > 16'd800);
                vu_meter[5]  <= (max_mag > 16'd1600);
                vu_meter[6]  <= (max_mag > 16'd3200);
                vu_meter[7]  <= (max_mag > 16'd5000);
                vu_meter[8]  <= (max_mag > 16'd7000);
                vu_meter[9]  <= (max_mag > 16'd9000);
                vu_meter[10] <= (max_mag > 16'd12000);
                vu_meter[11] <= (max_mag > 16'd15000);
                vu_meter[12] <= (max_mag > 16'd18000);
                vu_meter[13] <= (max_mag > 16'd22000);
                vu_meter[14] <= (max_mag > 16'd26000);
                vu_meter[15] <= (max_mag > 16'd30000);
                
                max_mag <= 16'd0; // Reset for next frame
                bin_cnt <= 9'd0;
            end else begin
                bin_cnt <= bin_cnt + 9'd1;
            end
        end
    end

    // Final output to physical pins
    assign led = vu_meter;

endmodule