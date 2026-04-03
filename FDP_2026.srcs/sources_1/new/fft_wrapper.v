`timescale 1ns / 1ps

module fft_wrapper (
    input  wire        clk,          // 100MHz system clock
    input  wire        reset_n,      // Active-low reset
    input  wire [11:0] mic_data,     // 12-bit unsigned from MIC3
    input  wire        mic_valid,    // 16kHz valid pulse

    // AXI-Stream Master Interface to FFT
    output reg  [15:0] m_axis_tdata,
    output reg         m_axis_tvalid,
    input  wire        m_axis_tready,
    output reg         m_axis_tlast
);

    // ==========================================
    // 1. DC Removal & Pre-emphasis Filter
    // ==========================================
    reg  signed [15:0] x_n, x_prev;
    wire signed [15:0] y_pre;
    
    always @(posedge clk) begin
        if (!reset_n) begin
            x_n <= 0;
            x_prev <= 0;
        end else if (mic_valid) begin
            // Remove DC offset (~2048) and sign extend
            x_n <= $signed({4'b0, mic_data}) - 16'sd2048; 
            x_prev <= x_n;
        end
    end

    // y[n] = x[n] - 0.97 * x[n-1]
    // 0.97 approx = 124/128 (Right shift by 7)
    assign y_pre = x_n - ((124 * x_prev) >>> 7);


    // ==========================================
    // 2. Circular Buffer (Forced to Block RAM)
    // ==========================================
    (* ram_style = "block" *) reg signed [15:0] buffer [0:399];
    
    reg [8:0] wr_ptr = 0;
    reg [8:0] hop_count = 0;
    reg       start_burst = 0;

    always @(posedge clk) begin
        if (!reset_n) begin
            wr_ptr <= 0;
            hop_count <= 0;
            start_burst <= 0;
        end else if (mic_valid) begin
            buffer[wr_ptr] <= y_pre;
            wr_ptr <= (wr_ptr == 399) ? 0 : wr_ptr + 1;
            
            // Trigger 10ms hop (every 160 samples)
            if (hop_count == 159) begin
                hop_count <= 0;
                start_burst <= 1;
            end else begin
                hop_count <= hop_count + 1;
            end
        end else begin
            start_burst <= 0; // Turn off pulse
        end
    end


    // ==========================================
    // 3. Hamming Window ROM Instantiation
    // ==========================================
    wire [15:0] rom_data_out;
    reg  [8:0]  rom_address;
    
    // Instantiate the Block Memory Generator IP you created
    hamming_rom window_lut (
        .clka(clk),
        .addra(rom_address),
        .douta(rom_data_out)
    );


    // ==========================================
    // 4. AXI-Stream Burst FSM
    // ==========================================
    reg [2:0] state;
    localparam IDLE       = 3'd0, 
               BURST_READ = 3'd1, 
               BURST_MULT = 3'd2, 
               BURST_PAD  = 3'd3;
               
    reg [9:0] burst_count;
    reg [8:0] rd_ptr;
    
    reg signed [15:0] ram_data_reg;

    always @(posedge clk) begin
        if (!reset_n) begin
            state <= IDLE;
            m_axis_tvalid <= 0;
            m_axis_tlast <= 0;
            m_axis_tdata <= 0;
        end else begin
            case (state)
                IDLE: begin
                    m_axis_tvalid <= 0;
                    m_axis_tlast <= 0;
                    if (start_burst) begin
                        state <= BURST_READ;
                        burst_count <= 0;
                        rd_ptr <= wr_ptr; // Start at oldest sample
                        rom_address <= 0;
                    end
                end

                // State 1: Ask RAM and ROM for data
                BURST_READ: begin
                    if (m_axis_tready) begin
                        // RAM and ROM read takes 1 clock. 
                        // The addresses are set. We wait 1 cycle.
                        ram_data_reg <= buffer[rd_ptr];
                        state <= BURST_MULT;
                    end
                end

                // State 2: Multiply and Output
                BURST_MULT: begin
                    if (m_axis_tready) begin
                        // Multiply buffer data by Q0.15 Hamming window, shift back down
                        m_axis_tdata <= (ram_data_reg * $signed({1'b0, rom_data_out})) >>> 15;
                        m_axis_tvalid <= 1;
                        
                        // Prep addresses for the NEXT read
                        rd_ptr <= (rd_ptr == 399) ? 0 : rd_ptr + 1;
                        rom_address <= rom_address + 1;
                        
                        burst_count <= burst_count + 1;
                        
                        if (burst_count == 399) begin
                            state <= BURST_PAD;
                        end else begin
                            state <= BURST_READ; // Loop back for next sample
                        end
                    end
                end

                // State 3: Zero Padding (Samples 400 to 511)
                BURST_PAD: begin
                    if (m_axis_tready) begin
                        m_axis_tdata <= 16'h0000;
                        m_axis_tvalid <= 1;
                        
                        burst_count <= burst_count + 1;
                        
                        if (burst_count == 511) begin
                            m_axis_tlast <= 1;
                        end
                        if (burst_count == 512) begin
                            m_axis_tvalid <= 0;
                            m_axis_tlast <= 0;
                            state <= IDLE;
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule