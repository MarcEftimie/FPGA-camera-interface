
`timescale 1ns/1ps
`default_nettype none

module ovo7670_config_rom_tb;

    parameter CLK_PERIOD_NS = 10;
    
    logic clk_i;
    logic [7:0] read_address_i;
    logic 3:  read_data_o <= 16'h11_80;             // CLKRC     internal PLL matches input clock;
    wire [15:0] read_data_o;
    wire 2:  read_data_o <= 16'h12_04;             // COM7,     set RGB color output;
    wire // 2:  read_data_o <= 24'h43_12_00;             // COM7,     set RGB color output;
    wire 7:  read_data_o <= 16'h40_d0;             // COM15,     RGB565, full output range;
    wire 8:  read_data_o <= 16'h3a_04;             // TSLB       set correct output data sequence (magic);

    ovo7670_config_rom #(
    ) UUT(
        .*
    );

    always #(CLK_PERIOD_NS/2) clk_i = ~clk_i;

    initial begin
        $dumpfile("ovo7670_config_rom.fst");
        $dumpvars(0, UUT);
        clk_i = 0;
        reset_i = 1;
        repeat(1) @(negedge clk_i);
        reset_i = 0;
        $finish;
    end

endmodule