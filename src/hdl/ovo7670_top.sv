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
        input wire vsync_cmos_i, href_cmos_i,
        input wire [7:0] pixel_data_cmos_i,
        output logic reset_cmos_o,
        output logic power_mode_cmos_o,
        output logic main_clk_cmos_o,
        output logic vsync_o,
        output logic hsync_o,
        output logic [3:0] vga_red_o, vga_blue_o, vga_green_o
    );

    logic [9:0] count;
    always_ff @(posedge main_clk_cmos_o, posedge reset_i) begin
        if (reset_i) begin
            reset_cmos_o <= 1;
            count <= 1023;     
        end else begin
            if (count == 0) begin
                reset_cmos_o <= 0;
            end else begin
                count <= count - 1;
            end
        end
    end

    clk_25MHz SYNC_PULSE_CLK(
        .clk_i(clk_i),
        .clk_o(main_clk_cmos_o)
    );

    // assign reset_cmos_o = 0;
    assign power_mode_cmos_o = 0;

    logic video_en;
    logic [$clog2(ACTIVE_COLUMNS)-1:0] pixel_x;
    logic [$clog2(ACTIVE_ROWS)-1:0] pixel_y;
    logic [$clog2(76800)-1:0] pixel_count;
    
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

    logic [11:0] pixel_data;

    vram_controller VRAM_CONTROLLER (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .pixel_clk_cmos_i(pixel_clk_cmos_i),
        .href_cmos_i(href_cmos_i),
        .pixel_data_cmos_i(pixel_data_cmos_i),
        .pixel_read_address_i(pixel_count),
        .pixel_data_o(pixel_data)
    );

    // assign vsync_o = vsync_cmos_i;
    // assign hsync_o = hsync_cmos_i;
    assign vga_red_o = video_en ? pixel_data[11:8] : 4'h0;
    assign vga_green_o = video_en ? pixel_data[7:4] : 4'h0;
    assign vga_blue_o = video_en ? pixel_data[3:0] : 4'h0;

    // assign vga_red_o = pixel_data_cmos_i[3:0];
    // assign vga_blue_o = pixel_data_cmos_i[3:0];
    // assign vga_green_o = pixel_data_cmos_i[3:0];

    logic clk_100_khz;

    clk_100KHz CLK_100KHZ_I2C_CONTROLLER(.clk_i(clk_i), .clk_o(clk_100_khz));

    typedef enum logic [3:0] {
        RESET,
        DELAY,
        WRITE,
        DONE
    } state_t;

    state_t state_q;
    state_t state_d;

    logic reset_q;
    logic reset_d;

    logic [15:0] timer_q;
    logic [15:0] timer_d;

    logic [7:0] rd_addr_q;
    logic [7:0] rd_addr_d;

    logic [7:0] rd_data_q;
    logic [7:0] rd_data_d;

    logic [23:0] wr_data;
    logic [7:0] rd_data;
    
    logic [3:0] ack_q;
    logic [3:0] ack_d;

    logic valid;
    logic ready;

    // Flops
    always_ff @(posedge clk_100_khz) begin
        if (reset_i) begin
            state_q <= RESET;
            reset_q <= 1'b1;
            timer_q <= 3;
            rd_addr_q <= 1;
            rd_data_q <= 8'h0;
            ack_q <= 4'h0;
        end else begin
            state_q <= state_d;
            ack_q <= ack_d;
            rd_addr_q <= rd_addr_d;
            reset_q <= reset_d;
            timer_q <= timer_d;
            rd_data_q <= rd_data_d;
        end
    end

    // Combinational Logic

    always_comb begin
        reset_d = 1'b0;
        state_d = RESET;
        rd_addr_d = rd_addr_q;
        rd_data_d = rd_data_q;
        valid = 1'b0;
        case (state_q)
            RESET : begin
                if (timer_q != 0) begin
                    timer_d = timer_q - 1;
                    reset_d = 1'b1;
                    state_d = RESET;
                end else begin
                    timer_d = 10;
                    state_d = DELAY;
                end
            end
            DELAY : begin
                if (timer_q != 0) begin
                    timer_d = timer_q - 1;
                    state_d = DELAY;
                end else begin
                    state_d = WRITE;
                end
            end
            WRITE : begin
                if (ready) begin
                    valid = 1'b1;
                    rd_addr_d = rd_addr_q + 1;
                end else begin
                    valid = 1'b0;
                end
                if (rd_addr_q == 1) begin
                    rd_data_d = rd_data;
                    state_d = DONE;
                end else begin
                    state_d = WRITE;
                end
            end
            DONE : begin
                state_d = DONE;
            end
        endcase
    end

endmodule
