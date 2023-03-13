`timescale 1ns/1ps
`default_nettype none

module i2c_controller
    #(
        parameter RESET_DELAY = 65535
    )
    (
        input wire clk_i, reset_i,
        inout tri sda_io,
        output tri scl_o,
        output logic reset_cmos_o,
        output logic error_o
    );

    logic clk_100_khz;

    clk_50KHz CLK_50KHZ(.clk_i(clk_i), .clk_o(clk_100_khz));

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

    assign sda_io = (state_reg == DELAY || state_next == DONE) ? 1'b1 : 
                    (state_reg == RESET) ? 1'b0 : sda_i2c;
    assign scl_o =  (state_next == DONE) ? 1'b1 : (delay_state == WRITE) ? scl_i2c : 1'b0;

    tri sda_i2c;
    logic scl_i2c;
    state_t delay_state;

    i2c I2C(
        .clk_i(clk_i),
        .reset_i(reset_i),
        .clk_100_khz(clk_100_khz),
        .write_data_i(i2c_write_data),
        .valid_i(valid_reg),
        .sda_io(sda_i2c),
        .scl_o(scl_i2c),
        .ready_o(ready),
        .done_o(done),
        .error_o(error_o)
    );

    // Registers
    always_ff @(posedge clk_100_khz, posedge reset_i) begin
        if (reset_i) begin
            state_reg <= RESET;
            delay_state <= RESET;
            timer_reg <= RESET_DELAY;
            valid_reg <= 0;
            read_address_reg <= 255;
        end else begin
            state_reg <= state_next;
            read_address_reg <= read_address_next;
            valid_reg <= valid_next;
            timer_reg <= timer_next;
            delay_state <= state_reg;
        end
    end

    // Next State logic
    always_comb begin
        state_next = RESET;
        read_address_next = read_address_reg;
        valid_next = 1'b0;
        reset_cmos_o = 1'b1;
        case (state_reg)
            RESET : begin
                if (timer_reg > 0) begin
                    timer_next = timer_reg - 1;
                    reset_cmos_o = 1'b0;
                    state_next = RESET;
                end else begin
                    timer_next = RESET_DELAY;
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
                reset_cmos_o = 1'b0;
            end
            WRITE : begin
                if (ready) begin
                    valid_next = 1'b1;
                    read_address_next = read_address_reg + 1;
                end
                if (read_address_reg == 78) begin
                    state_next = DONE;
                end else begin
                    state_next = WRITE;
                end
            end
            DONE : begin
                state_next = DONE;
            end
            default : state_next = RESET;
        endcase
    end

endmodule
