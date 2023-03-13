`timescale 1ns/1ps
`default_nettype none

module ovo7670_config_rom(
    input wire clk_i,
    input wire [7:0] read_address_i,
    output logic [15:0] read_data_o
);

    always_ff @(posedge clk_i) begin
        case(read_address_i)
            0: read_data_o <= 16'h12_80;  //reset all register to default values
            1: read_data_o <= 16'h12_04;  //set output format to RGB
            2: read_data_o <= 16'h15_20;  //pclk will not toggle during horizontal blank
            3: read_data_o <= 16'h40_d0;	//   
            4: read_data_o <= 16'h12_04; // COM7,     set RGB color output
            5: read_data_o <= 16'h11_80; // CLKRC     internal PLL matches input clock
            6: read_data_o <= 16'h0C_00; // COM3,     default settings
            7: read_data_o <= 16'h3E_00; // COM14,    no scaling, normal pclock
            8: read_data_o <= 16'h04_00; // COM1,     disable CCIR656
            9: read_data_o <= 16'h40_d0; //COM15,     RGB565, full output range
            10: read_data_o <= 16'h3a_04; //TSLB       set correct output data sequence (magic)
            11: read_data_o <= 16'h14_18; //COM9       MAX AGC value x4 0001_1000
            12: read_data_o <= 16'h4F_B3; //MTX1       all of these are magical matrix coefficients
            13: read_data_o <= 16'h50_B3; //MTX2
            14: read_data_o <= 16'h51_00; //MTX3
            15: read_data_o <= 16'h52_3d; //MTX4
            16: read_data_o <= 16'h53_A7; //MTX5
            17: read_data_o <= 16'h54_E4; //MTX6
            18: read_data_o <= 16'h58_9E; //MTXS
            19: read_data_o <= 16'h3D_C0; //COM13      sets gamma enable, does not preserve reserved bits, may be wrong?
            20: read_data_o <= 16'h17_14; //HSTART     start high 8 bits
            21: read_data_o <= 16'h18_02; //HSTOP      stop high 8 bits //these kill the odd colored line
            22: read_data_o <= 16'h32_80; //HREF       edge offset
            23: read_data_o <= 16'h19_03; //VSTART     start high 8 bits
            24: read_data_o <= 16'h1A_7B; //VSTOP      stop high 8 bits
            25: read_data_o <= 16'h03_0A; //VREF       vsync edge offset
            26: read_data_o <= 16'h0F_41; //COM6       reset timings
            27: read_data_o <= 16'h1E_00; //MVFP       disable mirror / flip //might have magic value of 03
            28: read_data_o <= 16'h33_0B; //CHLF       //magic value from the internet
            29: read_data_o <= 16'h3C_78; //COM12      no HREF when VSYNC low
            30: read_data_o <= 16'h69_00; //GFIX       fix gain control
            31: read_data_o <= 16'h74_00; //REG74      Digital gain control
            32: read_data_o <= 16'hB0_84; //RSVD       magic value from the internet *required* for good color
            33: read_data_o <= 16'hB1_0c; //ABLC1
            34: read_data_o <= 16'hB2_0e; //RSVD       more magic internet values
            35: read_data_o <= 16'hB3_80; //THL_ST
            36: read_data_o <= 16'h70_3a;
            37: read_data_o <= 16'h71_35;
            38: read_data_o <= 16'h72_11;
            39: read_data_o <= 16'h73_f0;
            40: read_data_o <= 16'ha2_02;
            41: read_data_o <= 16'h7a_20;
            42: read_data_o <= 16'h7b_10;
            43: read_data_o <= 16'h7c_1e;
            44: read_data_o <= 16'h7d_35;
            45: read_data_o <= 16'h7e_5a;
            46: read_data_o <= 16'h7f_69;
            47: read_data_o <= 16'h80_76;
            48: read_data_o <= 16'h81_80;
            49: read_data_o <= 16'h82_88;
            50: read_data_o <= 16'h83_8f;
            51: read_data_o <= 16'h84_96;
            52: read_data_o <= 16'h85_a3;
            53: read_data_o <= 16'h86_af;
            54: read_data_o <= 16'h87_c4;
            55: read_data_o <= 16'h88_d7;
            56: read_data_o <= 16'h89_e8;
            57: read_data_o <= 16'h13_e0; //COM8, disable AGC / AEC
            58: read_data_o <= 16'h00_00; //set gain reg to 0 for AGC
            59: read_data_o <= 16'h10_00; //set ARCJ reg to 0
            60: read_data_o <= 16'h0d_40; //magic reserved bit for COM4
            61: read_data_o <= 16'h14_18; //COM9, 4x gain + magic bit
            62: read_data_o <= 16'ha5_05; // BD50MAX
            63: read_data_o <= 16'hab_07; //DB60MAX
            64: read_data_o <= 16'h24_95; //AGC upper limit
            65: read_data_o <= 16'h25_33; //AGC lower limit
            66: read_data_o <= 16'h26_e3; //AGC/AEC fast mode op region
            67: read_data_o <= 16'h9f_78; //HAECC1
            68: read_data_o <= 16'ha0_68; //HAECC2
            69: read_data_o <= 16'ha1_03; //magic
            70: read_data_o <= 16'ha6_d8; //HAECC3
            71: read_data_o <= 16'ha7_d8; //HAECC4
            72: read_data_o <= 16'ha8_f0; //HAECC5
            73: read_data_o <= 16'ha9_90; //HAECC6
            74: read_data_o <= 16'haa_94; //HAECC7
            75: read_data_o <= 16'h13_e5; //COM8, enable AGC / AEC
            76: read_data_o <= 16'h1E_23; //Mirror Image
            77: read_data_o <= 16'h69_06; //gain of RGB(manually adjusted)
            // 1: read_data_o <= 16'h1280;
            // 2: read_data_o <= 16'h1280;
            // 3: read_data_o <= 16'h1204;
            // 4: read_data_o <= 16'h1100;
            // 5: read_data_o <= 16'h0C00;
            // 6: read_data_o <= 16'h3E00;
            // 7: read_data_o <= 16'h8C00;
            // 8: read_data_o <= 16'h0400;
            // 9: read_data_o <= 16'h4010;
            // 10: read_data_o <= 16'h3a04;
            // 11: read_data_o <= 16'h1438;
            // 12: read_data_o <= 16'h4fb3;
            // 13: read_data_o <= 16'h50b3;
            // 14: read_data_o <= 16'h5100;
            // 15: read_data_o <= 16'h523d;
            // 16: read_data_o <= 16'h53a7;
            // 17: read_data_o <= 16'h54e4;
            // 18: read_data_o <= 16'h589e;
            // 19: read_data_o <= 16'h3dc0;
            // 20: read_data_o <= 16'h1100;
            // 21: read_data_o <= 16'h1711;
            // 22: read_data_o <= 16'h1861;
            // 23: read_data_o <= 16'h32A4;
            // 24: read_data_o <= 16'h1903;
            // 25: read_data_o <= 16'h1A7b;
            // 26: read_data_o <= 16'h030a;
            // 27: read_data_o <= 16'h0e61;
            // 28: read_data_o <= 16'h0f4b;
            // 29: read_data_o <= 16'h1602;
            // 30: read_data_o <= 16'h1e37;
            // 31: read_data_o <= 16'h2102;
            // 32: read_data_o <= 16'h2291;
            // 33: read_data_o <= 16'h2907;
            // 34: read_data_o <= 16'h330b;
            // 35: read_data_o <= 16'h350b;
            // 36: read_data_o <= 16'h371d;
            // 37: read_data_o <= 16'h3871;
            // 38: read_data_o <= 16'h392a;
            // 39: read_data_o <= 16'h3c78;
            // 40: read_data_o <= 16'h4d40;
            // 41: read_data_o <= 16'h4e20;
            // 42: read_data_o <= 16'h6900;
            // 43: read_data_o <= 16'h6b4a;
            // 44: read_data_o <= 16'h7410;
            // 45: read_data_o <= 16'h8d4f;
            // 46: read_data_o <= 16'h8e00;
            // 47: read_data_o <= 16'h8f00;
            // 48: read_data_o <= 16'h9000;
            // 49: read_data_o <= 16'h9100;
            // 50: read_data_o <= 16'h9600;
            // 51: read_data_o <= 16'h9a00;
            // 52: read_data_o <= 16'hb084;
            // 53: read_data_o <= 16'hb10c;
            // 54: read_data_o <= 16'hb20e;
            // 55: read_data_o <= 16'hb382;
            // 56: read_data_o <= 16'hb80a;
            default: read_data_o <= 16'hFF_FF;        // mark end of ROM
                endcase
    end

endmodule
