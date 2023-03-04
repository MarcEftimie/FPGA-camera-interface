`timescale 1ns/1ps
`default_nettype none

module i2c(
    input wire clk_i, reset_i,
    input wire clk_100_khz,
    input wire [15:0] write_data_i,
    input wire valid_i,
    inout wire sda_io,
    output logic scl_o,
    output logic ready_o,
    output logic done
);  

    // Defines
    typedef enum logic [4:0] {
        IDLE,
        START_BIT,
        WRITE_ADDRESS_BYTE,
        WRITE_DATA_BYTE,
        ACK_BIT,
        ACK_STOP_BIT,
        STOP_BIT,
        DONE
    } state_d;

    logic clk_200_khz;
    
    state_d state_reg, state_next;

    logic [2:0] bit_count_reg, bit_count_next;
    logic delay_reg, delay_next;

    logic ready;

    logic sda;

    // Modules
    clk_200KHz CLK_200KHZ(.clk_i(clk_i), .clk_o(clk_200_khz));

    // Registers
    always_ff @(posedge clk_200_khz, posedge reset_i) begin
        if (reset_i) begin
            state_reg <= IDLE;
            bit_count_reg <= 7;
            delay_reg <= 0;
        end else begin
            state_reg <= state_next;
            bit_count_reg <= bit_count_next;
            delay_reg <= delay_next;
        end
    end

    // Next State Logic
    always_comb begin
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
                sda = write_data_i[8 + bit_count_reg];
                if (bit_count_reg == 0) begin
                    state_next = ACK_BIT;
                end else begin
                    if (delay_reg) begin
                        bit_count_next = bit_count_reg - 1;
                    end
                    delay_next = ~delay_reg;
                end
            end
            ACK_BIT : begin
                bit_count_next = 7;
                delay_next = 0;
                state_next = WRITE_DATA_BYTE;
            end
            WRITE_DATA_BYTE : begin
                sda = write_data_i[{1'b0, bit_count_reg}];
                if (bit_count_reg == 0) begin
                    bit_count_next = 7;
                    state_next = ACK_STOP_BIT;
                end else begin
                    bit_count_next = bit_count_reg - 1;
                end
            end 
            ACK_STOP_BIT : begin
                state_next = STOP_BIT;
            end
            STOP_BIT : begin
                sda = 0;
                state_next = DONE;
            end
            DONE : begin
                done = 1;
                sda = 0;
                state_next = IDLE;
            end
            default : begin
                state_next = IDLE;
            end
        endcase
    end

    // Outputs
    assign sda_io = sda ? 1'bz : 1'b0;
    assign scl_o = ((state_reg == IDLE) | clk_100_khz) ? 1'bz : 1'b0;
    assign ready_o = ready;

endmodule
