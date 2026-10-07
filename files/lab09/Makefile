# Lesson 9 lab
sim:
	iverilog -g2012 -Wall -o sim.out regfile.sv regfile_tb.sv
	vvp -n sim.out

fifo:
	iverilog -g2012 -Wall -o fifo.out sync_fifo.sv sync_fifo_tb.sv
	vvp -n fifo.out

lint:
	verilator --lint-only -Wall regfile.sv
	verilator --lint-only -Wall sync_fifo.sv

clean:
	rm -f *.out dump.vcd

.PHONY: sim fifo lint clean
