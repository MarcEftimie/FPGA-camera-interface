`timescale 1ns/1ps
`default_nettype none

module vram_controller
    (
        input wire clk_i, reset_i,
        input wire href_cmos_i,
        input wire [7:0] pixel_data_cmos_i,
        input wire [$clog2(76800)-1:0] pixel_read_address_i,
        output wire [7:0] pixel_data_o
    );

    logic vram_write_address_reg, vram_write_address_next;

    register_file #(
        .ADDR_WIDTH($clog2(76800)),
        .DATA_WIDTH(12),
        .RAM_LENGTH(76800),
        .ROM_FILE("zeros.mem")
    ) VRAM (
        .clk_i(clk_i),
        .wr_en(href_cmos_i),
        .wr_address_i(vram_write_address_reg),
        .rd_address_i(pixel_read_address_i),
        .wr_data_i(pixel_data_sync_2_reg),
        .rd_data_o(pixel_data_o)
    );

    logic [7:0] pixel_data_sync_1_reg, pixel_data_sync_1_next;
    logic [7:0] pixel_data_sync_2_reg, pixel_data_sync_2_next;
    logic href_sync_1_reg, href_sync_1_next;
    logic href_sync_2_reg, href_sync_2_next;

    always_ff @(posedge clk_i, posedge reset_i) begin
        if (reset_i) begin
            pixel_data_sync_1_reg <= 8'b00000000;
            pixel_data_sync_2_reg <= 8'b00000000;
            href_sync_1_reg <= 0;
            href_sync_2_reg <= 0;
            vram_write_address_reg <= 0;
        end else begin
            pixel_data_sync_1_reg <= pixel_data_sync_1_next;
            pixel_data_sync_2_reg <= pixel_data_sync_2_next;
            href_sync_1_reg <= href_sync_1_next;
            href_sync_2_reg <= href_sync_2_next;
            vram_write_address_reg <= vram_write_address_next;
        end
    end

    always_comb begin
        pixel_data_sync_1_next = pixel_data_cmos_i;
        pixel_data_sync_2_next = pixel_data_sync_1_reg;
        href_sync_1_next = href_cmos_i;
        href_sync_2_next = href_sync_1_reg;
    end

    always_comb begin
        if (href_sync_2_reg) begin
            if (vram_write_address_reg < 76800) begin
                vram_write_address_next = vram_write_address_reg + 1;
            end else begin
                vram_write_address_next = 0;
            end
        end else begin
            vram_write_address_next = vram_write_address_reg;
        end
    end


endmodule
