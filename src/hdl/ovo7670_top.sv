`timescale 1ns/1ps
`default_nettype none

module ovo7670_top
    #(
        parameter ACTIVE_COLUMNS = 640,
        parameter ACTIVE_ROWS = 480,
        parameter VRAM_ADDR_WIDTH = $clog2(ACTIVE_COLUMNS*ACTIVE_ROWS)
    ) (
        input wire clk_i, reset_i,
        input wire pixel_clk_cmos_i,
        input wire vsync_cmos_i, hsync_cmos_i,
        input wire [7:0] pixel_data_cmos_i,
        output logic reset_cmos_o,
        output logic power_mode_cmos_o,
        output logic main_clk_cmos_o,
        output logic vsync_o,
        output logic hsync_o,
        output logic [3:0] vga_red_o, vga_blue_o, vga_green_o
    );

    clk_25MHz SYNC_PULSE_CLK(
        .clk_i(clk_i),
        .clk_o(main_clk_cmos_o)
    );

    assign reset_cmos_o = 0;
    assign power_mode_cmos_o = 0;

    logic video_en;
    logic [$clog2(ACTIVE_COLUMNS)-1:0] pixel_x;
    logic [$clog2(ACTIVE_ROWS)-1:0] pixel_y;
    logic [VRAM_ADDR_WIDTH-1:0] pixel_count;
    
    sync_pulse_generator SYNC_PULSE_GENERATOR (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .hsync_o(hsync_o),
        .vsync_o(vsync_o),
        .video_en_o(video_en),
        .x_o(pixel_x),
        .y_o(pixel_y),
        .pixel_o(pixel_count)
    );

    // assign vsync_o = vsync_cmos_i;
    // assign hsync_o = hsync_cmos_i;
    assign vga_red_o = video_en ? pixel_data_cmos_i[3:0] : 4'h0;
    assign vga_blue_o = video_en ? pixel_data_cmos_i[7:4] : 4'h0;
    assign vga_green_o = video_en ? 4'h0 : 4'h0;

    // assign vga_red_o = pixel_data_cmos_i[3:0];
    // assign vga_blue_o = pixel_data_cmos_i[3:0];
    // assign vga_green_o = pixel_data_cmos_i[3:0];

endmodule
