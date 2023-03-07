
`timescale 1ns/1ps
`default_nettype none

module dual_clock_ram_tb;

    parameter CLK_PERIOD_NS = 10;
    
    parameter WIDTH = 12;
    parameter DEPTH = 76800;
    logic _clk_i, read_clk_i;
    logic _en_i, read_en_i;
    logic _a_i;
    logic _address_i, read_address_i;
    logic _data_i;
    wire [WIDTH-1:0] read_data_o;

    dual_clock_ram #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) UUT(
        .*
    );

    always #(CLK_PERIOD_NS/2) clk_i = ~clk_i;

    initial begin
        $dumpfile("dual_clock_ram.fst");
        $dumpvars(0, UUT);
        clk_i = 0;
        reset_i = 1;
        repeat(1) @(negedge clk_i);
        reset_i = 0;
        $finish;
    end

endmodule