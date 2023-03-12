`timescale 1ns/1ps
`default_nettype none

module vram_controller
    #(
        parameter ADDR_WIDTH = $clog2((640*480)/4),
        parameter DATA_WIDTH = 12
    )
    (
        input wire clk_i, reset_i,
        input wire pixel_clk_cmos_i,
        input wire vsync_cmos_i,
        input wire href_cmos_i,
        input wire [7:0] pixel_data_cmos_i,
        input wire [ADDR_WIDTH-1:0] pixel_read_address_i,
        output wire [DATA_WIDTH-1:0] pixel_data_o
    );

    // Definitions

    logic [ADDR_WIDTH-1:0] vram_write_address_reg, vram_write_address_next;
    logic [DATA_WIDTH-1:0] vram_write_data_reg, vram_write_data_next;
    logic vram_write_en_reg, vram_write_en_next;
    logic byte_count_reg, byte_count_next;

    dual_clock_ram VRAM (
        .write_clk_i(pixel_clk_cmos_i),
        .read_clk_i(clk_i),
        .write_en_i(vram_write_en_next),
        .read_en_i(1'b1),
        .write_address_i(vram_write_address_reg),
        .read_address_i(pixel_read_address_i),
        .write_data_i(vram_write_data_next),
        .read_data_o(pixel_data_o)
    );

    // Registers

    always_ff @(posedge pixel_clk_cmos_i, posedge reset_i) begin
        if (reset_i) begin
            vram_write_address_reg <= 0;
            vram_write_data_reg <= 0;
            vram_write_en_reg <= 0;
            byte_count_reg <= 0;
        end else begin
            vram_write_address_reg <= vram_write_address_next;
            vram_write_data_reg <= vram_write_data_next;
            vram_write_en_reg <= vram_write_en_next;
            byte_count_reg <= byte_count_next;
        end
    end

    always_comb begin
        vram_write_address_next = vram_write_address_reg;
        vram_write_data_next = vram_write_data_reg;
        vram_write_en_next = 0;
        byte_count_next = byte_count_reg;
        if (vsync_cmos_i) begin
            vram_write_address_next = 0;
            byte_count_next = 0;
        end else if (href_cmos_i && (vram_write_address_reg < 76800)) begin
            if (~byte_count_reg) begin
                // Write first half of byte
                vram_write_data_next = {pixel_data_cmos_i[7:4], pixel_data_cmos_i[2:0], 5'b00000};
            end else begin
                // Write second half of byte
                vram_write_data_next = {vram_write_data_reg[11:5], pixel_data_cmos_i[7], pixel_data_cmos_i[4:1]};
                vram_write_address_next = vram_write_address_reg + 1;
                vram_write_en_next = 1;
            end
            byte_count_next = ~byte_count_reg;
        end
    end


endmodule
