
`timescale 1ns/1ps
`default_nettype none

module vram_controller_tb;

    parameter CLK_PERIOD_NS = 40;
    parameter CLK_2_PERIOD_NS = 41;
    
    parameter ADDR_WIDTH = 8;
    parameter DATA_WIDTH = 8;
    logic clk_i, reset_i;
    logic pixel_clk_cmos_i;
    logic vsync_cmos_i;
    logic href_cmos_i;
    logic [7:0] pixel_data_cmos_i;
    logic [ADDR_WIDTH-1:0] pixel_read_address_i;
    wire [DATA_WIDTH-1:0] pixel_data_o;

    vram_controller #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) UUT(
        .*
    );

    always #(CLK_PERIOD_NS/2) clk_i = ~clk_i;
    always #((CLK_2_PERIOD_NS)/2) pixel_clk_cmos_i = ~pixel_clk_cmos_i;

    initial begin
        $dumpfile("vram_controller.fst");
        $dumpvars(0, UUT);
        clk_i = 0;
        pixel_clk_cmos_i = 0;
        reset_i = 1;
        repeat(1) @(negedge clk_i);
        reset_i = 0;
        repeat(1000) @(negedge clk_i);
        $finish;
    end

endmodule
