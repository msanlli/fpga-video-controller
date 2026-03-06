`define MODEL_TECH
`timescale 1ns / 1ps

module tb_lcd_sync();

    // Clock and reset
    reg         CLK_50;        // 50 MHz board clock
    reg         RST_n;         // active-low asynchronous reset

    // DUT outputs
    wire        HD, VD, GREST, NCLK, DEN;
    wire [9:0]  Row;
    wire [10:0] Column;

    // Generate 50 MHz clock (period 20 ns)
    initial begin
        CLK_50 = 0;
        forever #10 CLK_50 = ~CLK_50;   // 10 ns high, 10 ns low
    end

    // Reset: active low, deassert after 100 ns
    initial begin
        RST_n = 0;
        #100;
        RST_n = 1;
    end

    // Instantiate the module under test
    lcd_sync dut (
        .CLK    (CLK_50),
        .RST_n  (RST_n),
        .HD     (HD),
        .VD     (VD),
        .GREST  (GREST),
        .NCLK   (NCLK),
        .DEN    (DEN),
        .Row    (Row),
        .Column (Column)
    );

    // Count vertical sync pulses to determine when a full frame has been displayed
    reg [3:0] frame_count;
    always @(negedge VD or negedge RST_n) begin
        if (!RST_n)
            frame_count <= 0;
        else
            frame_count <= frame_count + 1;
    end

    // Stop simulation after two complete frames (first VD after reset marks end of frame 1)
    initial begin
        // Wait a little after reset deassertion
        #1000;
        // Wait for two VD pulses
        wait (frame_count == 2);
        $display("Simulation finished after 2 frames (one full screen scan captured).");
        $stop;
    end

endmodule
