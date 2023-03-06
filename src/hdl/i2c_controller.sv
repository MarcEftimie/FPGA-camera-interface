`timescale 1ns/1ps
`default_nettype none

module i2c_controller 
    (
        input wire clk_i, reset_i,
        inout wire sda_io,
        output logic scl_o,
        output logic reset_cmos_o,
        output logic error_o
    );

    logic clk_100_khz;

    clk_100KHz CLK_100KHZ(.clk_i(clk_i), .clk_o(clk_100_khz));

    typedef enum logic [2:0] {
        IDLE,
        RESET,
        DELAY,
        WRITE,
        DONE
    } state_t;

    state_t state_reg, state_next;

    logic [15:0] timer_reg, timer_next;

    logic [7:0] read_address_reg, read_address_next;
    logic [15:0] i2c_write_data;

    logic [7:0] rd_data;

    logic valid_reg, valid_next;
    logic ready, done;

    ovo7670_config_rom CONFIG_ROM (
        .clk_i(clk_100_khz),
        .read_address_i(read_address_reg),
        .read_data_o(i2c_write_data)
    );

    i2c I2C(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .clk_100_khz(clk_100_khz),
        .write_data_i(i2c_write_data),
        .valid_i(valid_reg),
        .sda_io(sda_io),
        .scl_o(scl_o),
        .ready_o(ready),
        .done_o(done),
        .error_o(error_o)
    );

    // Registers
    always_ff @(posedge clk_100_khz, posedge reset_i) begin
        if (reset_i) begin
            state_reg <= RESET;
            timer_reg <= 65535;
            valid_reg <= 0;
            read_address_reg <= 0;
        end else begin
            state_reg <= state_next;
            read_address_reg <= read_address_next;
            valid_reg <= valid_next;
            timer_reg <= timer_next;
        end
    end

    // Next State logic
    always_comb begin
        state_next = RESET;
        read_address_next = read_address_reg;
        valid_next = 1'b0;
        reset_cmos_o = 1'bz;
        case (state_reg)
            RESET : begin
                if (timer_reg > 0) begin
                    timer_next = timer_reg - 1;
                    reset_cmos_o = 1'b1;
                    state_next = RESET;
                end else begin
                    timer_next = 65535;
                    state_next = DELAY;
                end
            end
            DELAY : begin
                if (timer_reg > 0) begin
                    timer_next = timer_reg - 1;
                    state_next = DELAY;
                end else begin
                    state_next = WRITE;
                end
            end
            WRITE : begin
                if (ready) begin
                    valid_next = 1'b1;
                    read_address_next = read_address_reg + 1;
                end
                if (read_address_reg < 72) begin
                    state_next = WRITE;
                end else begin
                    state_next = DONE;
                end
            end
            DONE : begin
                state_next = DONE;
            end
            default : state_next = RESET;
        endcase
    end

endmodule
