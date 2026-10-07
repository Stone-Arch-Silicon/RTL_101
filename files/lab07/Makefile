# Lesson 7 lab
sim:
	iverilog -g2012 -Wall -o sim.out full_adder.sv adder_n.sv counter_n.sv shift_reg.sv param_tb.sv
	vvp -n sim.out

gray:
	iverilog -g2012 -Wall -o gray.out bin2gray.sv gray2bin.sv gray_tb.sv
	vvp -n gray.out

lint:
	verilator --lint-only -Wall --top-module adder_n full_adder.sv adder_n.sv
	verilator --lint-only -Wall counter_n.sv
	verilator --lint-only -Wall shift_reg.sv

clean:
	rm -f *.out dump.vcd

.PHONY: sim gray lint clean
