
IVERILOG=iverilog -DSIMULATION -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array -g2012 -Y.sv -I ./hdl -I ./tests 
VVP=vvp
VVP_POST=-fst
VIVADO=vivado -mode batch -source
SRCS=hdl/*.sv
MEMS=mem/*.mem

.PHONY: clean submission remove_solutions

clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml *.out
	rm -rf .Xil

program_fpga_vivado: $(SRCS) $(MAIN_MEMSMEMORIES) main.bit build.tcl program.tcl Basys-3-Master.xdc
	@echo "########################################"
	@echo "#### Building FPGA bitstream        ####"
	@echo "########################################"
	${VIVADO} build.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Vivado)      ####"
	@echo "########################################"
	${VIVADO} program.tcl

test_sync_pulse_generator : testbenches/sync_pulse_generator_tb.sv hdl/*
	${IVERILOG} $^ -o sync_pulse_generator_tb.bin && ${VVP} sync_pulse_generator_tb.bin ${VVP_POST} && gtkwave sync_pulse_generator.fst -a testbenches/sy

test_clk_200KHz : testbenches/clk_200KHz_tb.sv hdl/*
	${IVERILOG} $^ -o clk_200KHz_tb.bin && ${VVP} clk_200KHz_tb.bin ${VVP_POST} && gtkwave clk_200KHz.fst -a testbenches/sy

test_ovo7670_config_rom : testbenches/ovo7670_config_rom_tb.sv hdl/*
	${IVERILOG} $^ -o ovo7670_config_rom_tb.bin && ${VVP} ovo7670_config_rom_tb.bin ${VVP_POST} && gtkwave ovo7670_config_rom.fst -a testbenches/sy

test_vram_controller : testbenches/vram_controller_tb.sv hdl/*
	${IVERILOG} $^ -o vram_controller_tb.bin && ${VVP} vram_controller_tb.bin ${VVP_POST} && gtkwave vram_controller.fst -a testbenches/sy

test_i2c : testbenches/i2c_tb.sv hdl/*
	${IVERILOG} $^ -o i2c_tb.bin && ${VVP} i2c_tb.bin ${VVP_POST} && gtkwave i2c.fst -a testbenches/sy

test_clk_25MHz : testbenches/clk_25MHz_tb.sv hdl/*
	${IVERILOG} $^ -o clk_25MHz_tb.bin && ${VVP} clk_25MHz_tb.bin ${VVP_POST} && gtkwave clk_25MHz.fst -a testbenches/sy

test_ovo7670_top : testbenches/ovo7670_top_tb.sv hdl/*
	${IVERILOG} $^ -o ovo7670_top_tb.bin && ${VVP} ovo7670_top_tb.bin ${VVP_POST} && gtkwave ovo7670_top.fst -a testbenches/sy

test_i2c_controller : testbenches/i2c_controller_tb.sv hdl/*
	${IVERILOG} $^ -o i2c_controller_tb.bin && ${VVP} i2c_controller_tb.bin ${VVP_POST} && gtkwave i2c_controller.fst -a testbenches/sy

test_clk_100KHz : testbenches/clk_100KHz_tb.sv hdl/*
	${IVERILOG} $^ -o clk_100KHz_tb.bin && ${VVP} clk_100KHz_tb.bin ${VVP_POST} && gtkwave clk_100KHz.fst -a testbenches/sy

test_dual_clock_ram : testbenches/dual_clock_ram_tb.sv hdl/*
	${IVERILOG} $^ -o dual_clock_ram_tb.bin && ${VVP} dual_clock_ram_tb.bin ${VVP_POST} && gtkwave dual_clock_ram.fst -a testbenches/sy

