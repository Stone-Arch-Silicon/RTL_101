# Lesson 3 lab
sim:
	iverilog -g2012 -Wall -o sim.out mux2.sv mux4.sv decoder2to4.sv comb_tb.sv
	vvp -n sim.out

adder:
	iverilog -g2012 -Wall -o adder.out full_adder.sv adder4.sv adder4_tb.sv
	vvp -n adder.out

lint:
	verilator --lint-only -Wall --top-module mux4 mux2.sv mux4.sv
	verilator --lint-only -Wall --top-module adder4 full_adder.sv adder4.sv

wave: sim
	gtkwave dump.vcd

clean:
	rm -f *.out dump.vcd

.PHONY: sim adder lint wave clean
