# Lesson 5 lab
sim:
	iverilog -g2012 -Wall -o sim.out counter.sv counter_tb.sv
	vvp -n sim.out

tick:
	iverilog -g2012 -Wall -o tick.out tick_gen.sv tick_gen_tb.sv
	vvp -n tick.out

wave: sim
	gtkwave dump.vcd

lint:
	verilator --lint-only -Wall counter.sv
	verilator --lint-only -Wall tick_gen.sv

clean:
	rm -f *.out dump.vcd

.PHONY: sim tick wave lint clean
