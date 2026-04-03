`timescale 1ns / 1ps

module spi_sim();

    reg basys3_clk;
    reg miso;
    wire cs, sclk, sample_valid;
    wire [11:0] sample_data;

    // The pattern you requested (Trash 0000 + Data ACD)
    reg [15:0] test_vector = 16'b0000_1010_1100_1101;

    mic_spi_interface uut (
        .basys3_clk(basys3_clk), 
        .miso(miso), 
        .cs(cs), 
        .sclk(sclk), 
        .sample_data(sample_data), 
        .sample_valid(sample_valid)
    );

    // 100MHz Clock
    initial begin
        basys3_clk = 0;
        forever #5 basys3_clk = ~basys3_clk;
    end

    // Task to handle one 16-bit SPI transaction
    task send_miso_frame;
        integer i;
        begin
            wait(cs == 0); // Wait for module to pull CS low
            $display("--- Starting Transaction at Time %t ---", $time);
            for (i = 15; i >= 0; i = i - 1) begin
                @(negedge sclk); // Provide data on falling edge
                miso = test_vector[i];
            end
            wait(sample_valid == 1);
            $display("Captured Data: %h", sample_data);
            #100; // Small buffer
        end
    endtask

    initial begin
        miso = 0;
        
        // Transaction 1
        send_miso_frame();
        
        // Transaction 2
        send_miso_frame();

        $display("Double Transaction Complete.");
        $finish;
    end

endmodule