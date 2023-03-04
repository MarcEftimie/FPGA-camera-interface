`timescale 1ns/1ps
`default_nettype none

module ovo7670_config_rom(
    input wire clk_i,
    input wire [7:0] read_address_i,
    output logic [15:0] read_data_o
);

    always_ff @(posedge clk_i) begin
        case(read_address_i)
            0:  read_data_o <= 16'hFF_F0;             // delay
            1:  read_data_o <= 16'h12_80;             // reset
            2:  read_data_o <= 16'h12_04;             // COM7,     set RGB color output
            // 2:  read_data_o <= 24'h43_12_00;             // COM7,     set RGB color output
            3:  read_data_o <= 16'h11_80;             // CLKRC     internal PLL matches input clock
            4:  read_data_o <= 16'h0C_00;             // COM3,     default settings
            5:  read_data_o <= 16'h3E_00;             // COM14,    no scaling, normal pclock
            6:  read_data_o <= 16'h04_00;             // COM1,     disable CCIR656
            7:  read_data_o <= 16'h40_d0;             // COM15,     RGB565, full output range
            8:  read_data_o <= 16'h3a_04;             // TSLB       set correct output data sequence (magic)
            9:  read_data_o <= 16'h14_18;             // COM9       MAX AGC value x4
            10: read_data_o <= 16'h4F_B3;             // MTX1       all of these are magical matrix coefficients
            11: read_data_o <= 16'h50_B3;             // MTX2
            12: read_data_o <= 16'h51_00;             // MTX3
            13: read_data_o <= 16'h52_3d;             // MTX4
            14: read_data_o <= 16'h53_A7;             // MTX5
            15: read_data_o <= 16'h54_E4;             // MTX6
            16: read_data_o <= 16'h58_9E;             // MTXS
            17: read_data_o <= 16'h3D_C0;             // COM13      sets gamma enable, does not preserve reserved bits, may be wrong?
            18: read_data_o <= 16'h17_14;             // HSTART     start high 8 bits
            19: read_data_o <= 16'h18_02;             // HSTOP      stop high 8 bits //these kill the odd colored line
            20: read_data_o <= 16'h32_80;             // HREF       edge offset
            21: read_data_o <= 16'h19_03;             // VSTART     start high 8 bits
            22: read_data_o <= 16'h1A_7B;             // VSTOP      stop high 8 bits
            23: read_data_o <= 16'h03_0A;             // VREF       vsync edge offset
            24: read_data_o <= 16'h0F_41;             // COM6       reset timings
            25: read_data_o <= 16'h1E_00;             // MVFP       disable mirror / flip //might have magic value of 03
            26: read_data_o <= 16'h33_0B;             // CHLF       //magic value from the internet
            27: read_data_o <= 16'h3C_78;             // COM12      no HREF when VSYNC low
            28: read_data_o <= 16'h69_00;             // GFIX       fix gain control
            29: read_data_o <= 16'h74_00;             // REG74      Digital gain control
            30: read_data_o <= 16'hB0_84;             // RSVD       magic value from the internet *required* for good color
            31: read_data_o <= 16'hB1_0c;             // ABLC1
            32: read_data_o <= 16'hB2_0e;             // RSVD       more magic internet values
            33: read_data_o <= 16'hB3_80;             // THL_ST
            // Begin mystery scaling numbers
            34: read_data_o <= 16'h70_3a;
            35: read_data_o <= 16'h71_35;
            36: read_data_o <= 16'h72_11;
            37: read_data_o <= 16'h73_f0;
            38: read_data_o <= 16'ha2_02;
            // Gamma curve values
            39: read_data_o <= 16'h7a_20;
            40: read_data_o <= 16'h7b_10;
            41: read_data_o <= 16'h7c_1e;
            42: read_data_o <= 16'h7d_35;
            43: read_data_o <= 16'h7e_5a;
            44: read_data_o <= 16'h7f_69;
            45: read_data_o <= 16'h80_76;
            46: read_data_o <= 16'h81_80;
            47: read_data_o <= 16'h82_88;
            48: read_data_o <= 16'h83_8f;
            49: read_data_o <= 16'h84_96;
            50: read_data_o <= 16'h85_a3;
            51: read_data_o <= 16'h86_af;
            52: read_data_o <= 16'h87_c4;
            53: read_data_o <= 16'h88_d7;
            54: read_data_o <= 16'h89_e8;
            //AGC and AEC
            54: read_data_o <= 16'h13_e0;             // COM8, disable AGC / AEC
            55: read_data_o <= 16'h00_00;             // set gain reg to 0 for AGC
            56: read_data_o <= 16'h10_00;             // set ARCJ reg to 0
            57: read_data_o <= 16'h0d_40;             // magic reserved bit for COM4
            58: read_data_o <= 16'h14_18;             // COM9, 4x gain + magic bit
            59: read_data_o <= 16'ha5_05;             // BD50MAX
            60: read_data_o <= 16'hab_07;             // DB60MAX
            61: read_data_o <= 16'h24_95;             // AGC upper limit
            62: read_data_o <= 16'h25_33;             // AGC lower limit
            63: read_data_o <= 16'h26_e3;             // AGC/AEC fast mode op region
            64: read_data_o <= 16'h9f_78;             // HAECC1
            65: read_data_o <= 16'ha0_68;             // HAECC2
            66: read_data_o <= 16'ha1_03;             // magic
            67: read_data_o <= 16'ha6_d8;             // HAECC3
            68: read_data_o <= 16'ha7_d8;             // HAECC4
            69: read_data_o <= 16'ha8_f0;             // HAECC5
            70: read_data_o <= 16'ha9_90;             // HAECC6
            71: read_data_o <= 16'haa_94;             // HAECC7
            72: read_data_o <= 16'h13_e5;             // COM8, enable AGC / AEC
            default: read_data_o <= 16'hFF_FF;        // mark end of ROM
                endcase
    end

endmodule
