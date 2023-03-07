
`timescale 1ns/1ps
`default_nettype none

module i2c_tb;

    parameter CLK_PERIOD_NS = 10;
    
    logic clk_i, reset_i;
    logic clk_100_khz;
    logic [15:0] write_data_i;
    logic valid_i;
    wire scl_o;
    wire ready_o;
    wire done_o;
    wire error_o;

    i2c #(
    ) UUT(
        .*
    );

    always #(CLK_PERIOD_NS/2) clk_i = ~clk_i;

    initial begin
        $dumpfile("i2c.fst");
        $dumpvars(0, UUT);
        clk_i = 0;
        reset_i = 1;
        repeat(1) @(negedge clk_i);
        reset_i = 0;
        $finish;
    end

endmodule