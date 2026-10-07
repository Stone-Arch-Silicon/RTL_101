# Lesson 10 lab
sim:
	iverilog -g2012 -Wall -o sim.out skid_buffer.sv skid_buffer_tb.sv
	vvp -n sim.out

mac:
	iverilog -g2012 -Wall -o mac.out mac_pipe.sv mac_pipe_tb.sv
	vvp -n mac.out

cdc:
	iverilog -g2012 -Wall -o cdc.out sync_2ff.sv pulse_sync.sv cdc_tb.sv
	vvp -n cdc.out

lint:
	verilator --lint-only -Wall skid_buffer.sv
	verilator --lint-only -Wall mac_comb.sv
	verilator --lint-only -Wall --top-module pulse_sync sync_2ff.sv pulse_sync.sv

clean:
	rm -f *.out dump.vcd

.PHONY: sim mac cdc lint clean
