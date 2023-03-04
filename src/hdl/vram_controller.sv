`timescale 1ns/1ps
`default_nettype none

module vram_controller
    #(
        parameter ADDR_WIDTH = $clog2(76800),
        parameter DATA_WIDTH = 12
    )
    (
        input wire clk_i, reset_i,
        input wire pixel_clk_cmos_i,
        input wire href_cmos_i,
        input wire [7:0] pixel_data_cmos_i,
        input wire [ADDR_WIDTH-1:0] pixel_read_address_i,
        output wire [DATA_WIDTH-1:0] pixel_data_o
    );

    // Definitions

    logic [ADDR_WIDTH-1:0] vram_write_address_reg, vram_write_address_next;
    logic [DATA_WIDTH-1:0] vram_write_data_reg, vram_write_data_next;
    logic byte_count_reg, byte_count_next;

    register_file #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH),
        .RAM_LENGTH(76800),
        .ROM_FILE("zeros.mem")
    ) VRAM (
        .clk_i(clk_i),
        .wr_en(href_sync_2_reg),
        .wr_address_i(vram_write_address_sync_2_reg),
        .rd_address_i(pixel_read_address_i),
        .wr_data_i(vram_write_data_sync_2_reg),
        .rd_data_o(pixel_data_o)
    );

    // Synchronizers

    logic [DATA_WIDTH-1:0] vram_write_data_sync_1_reg, vram_write_data_sync_1_next;
    logic [DATA_WIDTH-1:0] vram_write_data_sync_2_reg, vram_write_data_sync_2_next;
    logic [ADDR_WIDTH-1:0] vram_write_address_sync_1_reg, vram_write_address_sync_1_next;
    logic [ADDR_WIDTH-1:0] vram_write_address_sync_2_reg, vram_write_address_sync_2_next;
    logic href_sync_1_reg, href_sync_1_next;
    logic href_sync_2_reg, href_sync_2_next;

    always_ff @(posedge clk_i, posedge reset_i) begin
        if (reset_i) begin
            vram_write_data_sync_1_reg <= 0;
            vram_write_data_sync_2_reg <= 0;
            vram_write_address_sync_1_reg <= 0;
            vram_write_address_sync_2_reg <= 0;
            href_sync_1_reg <= 0;
            href_sync_2_reg <= 0;
        end else begin
            vram_write_data_sync_1_reg <= vram_write_data_sync_1_next;
            vram_write_data_sync_2_reg <= vram_write_data_sync_2_next;
            vram_write_address_sync_1_reg <= vram_write_address_sync_1_next;
            vram_write_address_sync_2_reg <= vram_write_address_sync_2_next;
            href_sync_1_reg <= href_sync_1_next;
            href_sync_2_reg <= href_sync_2_next;
        end
    end

    always_comb begin
        vram_write_data_sync_1_next = vram_write_data_reg;
        vram_write_data_sync_2_next = vram_write_data_sync_1_reg;
        vram_write_address_sync_1_next = vram_write_address_reg;
        vram_write_address_sync_2_next = vram_write_address_sync_1_reg;
        href_sync_1_next = href_cmos_i;
        href_sync_2_next = href_sync_1_reg;
    end

    // Registers

    always_ff @(posedge pixel_clk_cmos_i, posedge reset_i) begin
        if (reset_i) begin
            vram_write_address_reg <= 0;
            vram_write_data_reg <= 0;
            byte_count_reg <= 0;
        end else begin
            vram_write_address_reg <= vram_write_address_next;
            vram_write_data_reg <= vram_write_data_next;
            byte_count_reg <= byte_count_next;
        end
    end

    logic byte_count;

    always_comb begin
        if (href_cmos_i) begin
            if (~byte_count_reg) begin
                vram_write_data_next[11:5] = {pixel_data_cmos_i[7:4], pixel_data_cmos_i[2:0]};
            end else begin
                vram_write_data_next[4:0] = {pixel_data_cmos_i[7], pixel_data_cmos_i[4:1]};
            end
            if (vram_write_address_reg < 76800) begin
                if (byte_count_reg) begin
                    vram_write_address_next = vram_write_address_reg + 1;
                end
            end else begin
                vram_write_address_next = 0;
            end
            byte_count_next = ~byte_count_reg;
        end else begin
            vram_write_address_next = vram_write_address_reg;
            vram_write_data_next = vram_write_data_reg;
            byte_count_next = 0;
        end
    end


endmodule
