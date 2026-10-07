# Lesson 6 lab
sim:
	iverilog -g2012 -Wall -o sim.out seq_1011.sv seq_1011_tb.sv
	vvp -n sim.out

traffic:
	iverilog -g2012 -Wall -o traffic.out traffic.sv traffic_tb.sv
	vvp -n traffic.out

wave: sim
	gtkwave dump.vcd

lint:
	verilator --lint-only -Wall seq_1011.sv
	verilator --lint-only -Wall traffic.sv

clean:
	rm -f *.out dump.vcd

.PHONY: sim traffic wave lint clean
