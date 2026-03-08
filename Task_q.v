`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.03.2026 22:05:57
// Design Name: 
// Module Name: Task_q
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

module task_q(
    input clk6p25m,         // FIXED: Matches Top_Student exactly
    input btnD,                 // Down button
    input [12:0] pixel_index,   // From OLED driver
    output reg [15:0] oled_data // To OLED driver
);

    // Convert 1D pixel index to 2D X/Y coordinates
    wire [6:0] col = pixel_index % 96;
    wire [5:0] row = pixel_index / 96;

    // 16-bit RGB565 Colors
    localparam RED    = 16'hF800;
    localparam GREEN  = 16'h07E0;
    localparam BLUE   = 16'h001F;
    localparam YELLOW = 16'hFFE0;
    localparam BLACK  = 16'h0000;

// --- 1. DEBOUNCER & STATE MACHINE ---
    // 200ms at 100MHz is 20,000,000 clock cycles
    reg [19:0] debounce_counter = 0;
    reg btn_locked = 0;
    reg [1:0] state = 2'b00;

    always @(posedge clk6p25m) begin
        if (debounce_counter > 0) begin
            // We are in a lockout period (either pressing or releasing). Ignore all button activity.
            debounce_counter <= debounce_counter - 1;
        end
        else begin
            // Timer is at 0. We are ready to listen to the button.
            if (btnD == 1'b1 && !btn_locked) begin
                // 1. Valid Press Detected
                state <= state + 1;             
                debounce_counter <= 20'hFFFFF; // Start 200ms lockout to ignore press bounce
                btn_locked <= 1;                // Lock the button so holding it does nothing
            end
            else if (btnD == 1'b0 && btn_locked) begin
                // 2. Valid Release Detected
                debounce_counter <= 20'hFFFFF; // Start 200ms lockout to ignore release bounce
                btn_locked <= 0;                // Unlock the button for the next press
            end
        end
    end

    // --- 2. PIXEL DRAWING LOGIC ---
    reg [15:0] current_square_color;
    
    always @(*) begin
        // Determine center square color based on state
        case(state)
            2'b00: current_square_color = GREEN;
            2'b01: current_square_color = RED;
            2'b10: current_square_color = BLUE;
            2'b11: current_square_color = YELLOW;
        endcase

        // Default Background
        oled_data = BLACK;

        // A. Center Square (Bottom Middle: 20x20 pixels)
        // X: 38 to 57, Y: 44 to 63
        if (col >= 38 && col <= 57 && row >= 44 && row <= 63) begin
            oled_data = current_square_color;
        end
        
        // B. Left Character: Red '5' 
        // Bounding box: X: 10 to 29, Y: 44 to 63. Lines are 4px thick.
        else if (col >= 10 && col <= 29 && row >= 44 && row <= 47) oled_data = RED; // Top bar
        else if (col >= 10 && col <= 13 && row >= 48 && row <= 53) oled_data = RED; // Top-left vertical
        else if (col >= 10 && col <= 29 && row >= 51 && row <= 54) oled_data = RED; // Middle bar
        else if (col >= 26 && col <= 29 && row >= 55 && row <= 63) oled_data = RED; // Bottom-right vertical
        else if (col >= 10 && col <= 29 && row >= 60 && row <= 63) oled_data = RED; // Bottom bar

        // C. Right Character: Blue '1' 
        // Bounding box: X: 66 to 85, Y: 44 to 63. Lines are 4px thick.
        else if (col >= 73 && col <= 76 && row >= 44 && row <= 63) oled_data = BLUE; // Main vertical line
        else if (col >= 69 && col <= 73 && row >= 44 && row <= 47) oled_data = BLUE; // Top left tick
        else if (col >= 68 && col <= 81 && row >= 60 && row <= 63) oled_data = BLUE; // Bottom serif base
    end
endmodule
