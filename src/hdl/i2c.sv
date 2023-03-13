`timescale 1ns/1ps
`default_nettype none

module i2c
    (
        input wire clk_i, reset_i,
        input wire clk_100_khz,
        input wire [15:0] write_data_i,
        input wire valid_i,
        inout tri sda_io,
        output logic scl_o,
        output logic ready_o,
        output logic done_o,
        output logic error_o
    );  

    // Defines
    typedef enum logic [4:0] {
        IDLE,
        START_BIT,
        WRITE_ADDRESS_BYTE,
        WRITE_REG_ADDRESS_BYTE,
        WRITE_DATA_BYTE,
        ACK1_BIT,
        ACK2_BIT,
        ACK_STOP_BIT,
        STOP_BIT,
        DONE,
        DELAY
    } state_d;

    logic clk_200_khz;
    
    state_d state_reg, state_next;

    logic [2:0] bit_count_reg, bit_count_next;
    logic delay_reg, delay_next;

    logic ready;
    logic done;

    logic sda;

    logic error_reg, error_next;

    logic [7:0] address_byte;
    assign address_byte = 8'h42; 
    assign error_o = error_reg;

    // Modules
    clk_100KHz CLK_100KHZ(.clk_i(clk_i), .clk_o(clk_200_khz));

    // Registers
    always_ff @(posedge clk_200_khz, posedge reset_i) begin
        if (reset_i) begin
            state_reg <= IDLE;
            bit_count_reg <= 7;
            delay_reg <= 0;
            error_reg <= 0;
        end else begin
            state_reg <= state_next;
            bit_count_reg <= bit_count_next;
            delay_reg <= delay_next;
            error_reg <= error_next;
        end
    end

    // Next State Logic
    always_comb begin
        error_next = error_reg;
        ready = 0;
        sda = 1;
        bit_count_next = bit_count_reg;
        delay_next = delay_reg;
        done = 0;
        case(state_reg)
            IDLE : begin
                if (valid_i) begin
                    // sda = 0;
                    state_next = START_BIT;
                end else begin
                    ready = 1'b1;
                    state_next = IDLE;
                end
                bit_count_next = 7;
                delay_next = 0;
            end
            START_BIT : begin
                sda = 0;
                state_next = WRITE_ADDRESS_BYTE;
            end
            WRITE_ADDRESS_BYTE : begin
                sda = address_byte[bit_count_reg];
                if (bit_count_reg == 0 && delay_reg) begin
                    state_next = ACK1_BIT;
                end else begin
                    if (delay_reg) begin
                        bit_count_next = bit_count_reg - 1;
                    end
                    state_next = WRITE_ADDRESS_BYTE;
                end
                delay_next = ~delay_reg;
            end
            ACK1_BIT : begin
                bit_count_next = 7;
                sda = 0;
                if (delay_reg) begin
                    state_next = WRITE_REG_ADDRESS_BYTE;
                end else begin
                    if (sda_io != 0) begin
                        error_next = 1;
                    end
                    state_next = ACK1_BIT;
                end
                
                delay_next = ~delay_reg;
            end
            WRITE_REG_ADDRESS_BYTE : begin
                sda = write_data_i[8 + bit_count_reg];
                if (bit_count_reg == 0 && delay_reg) begin
                    state_next = ACK2_BIT;
                end else begin
                    if (delay_reg) begin
                        bit_count_next = bit_count_reg - 1;
                    end
                    state_next = WRITE_REG_ADDRESS_BYTE;
                end
                delay_next = ~delay_reg;
            end
            ACK2_BIT : begin
                bit_count_next = 7;
                sda = 0;
                if (delay_reg) begin
                    state_next = WRITE_DATA_BYTE;
                end else begin
                    if (sda_io != 0) begin
                        error_next = 1;
                    end
                    state_next = ACK2_BIT;
                end
                
                delay_next = ~delay_reg;
            end
            WRITE_DATA_BYTE : begin
                sda = write_data_i[{1'b0, bit_count_reg}];
                if (bit_count_reg == 0 && delay_reg) begin
                    bit_count_next = 7;
                    state_next = ACK_STOP_BIT;
                end else begin
                    if (delay_reg) begin
                        bit_count_next = bit_count_reg - 1;
                    end
                    state_next = WRITE_DATA_BYTE;
                end
                delay_next = ~delay_reg;
            end 
            ACK_STOP_BIT : begin
                sda = 0;
                if (delay_reg) begin
                    state_next = STOP_BIT;
                end else begin
                    if (sda_io != 0) begin
                        error_next = 1;
                    end
                    state_next = ACK_STOP_BIT;
                end
                delay_next = ~delay_reg;
            end
            STOP_BIT : begin
                sda = 0;
                bit_count_next = 7;
                state_next = DELAY;
            end
            DELAY: begin
                if (bit_count_reg == 0) begin
                    state_next = IDLE;
                end else begin
                    bit_count_next = bit_count_reg - 1;
                    state_next = DELAY;
                end
            end
            default : begin
                state_next = IDLE;
            end
        endcase
    end

    // Outputs
    assign sda_io = sda;
    // assign scl_o = clk_100_khz;
    assign scl_o = ((state_reg == IDLE || state_reg == DELAY) || clk_100_khz);
    assign ready_o = ready;
    assign done_o = done;

endmodule
