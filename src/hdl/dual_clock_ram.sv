`timescale 1ns / 1ps
`default_nettype none

module dual_clock_ram 
    #(
        parameter WIDTH = 12,
        parameter DEPTH = 76800
    )
    (
        input wire write_clk_i, read_clk_i,
        input wire write_en_i, read_en_i,
        input wire [$clog2(DEPTH)-1:0] write_address_i, read_address_i,
        input wire [WIDTH-1:0] write_data_i,
        output logic [WIDTH-1:0] read_data_o
    );

    logic [WIDTH-1:0] ram [DEPTH-1:0];

    always @(posedge write_clk_i) begin
        if (write_en_i) begin
            ram[write_address_i] <= write_data_i;
        end
    end

    always @(posedge read_clk_i) begin
        if (read_en_i) begin
            read_data_o <= ram[read_address_i];
        end
    end
endmodule
