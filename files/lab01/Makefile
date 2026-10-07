# Lesson 1 lab: run `make` to simulate, `make wave` to open the waveform.
SRC = half_adder.sv
TB  = half_adder_tb.sv

sim: $(SRC) $(TB)
	iverilog -g2012 -Wall -o sim.out $(SRC) $(TB)
	vvp -n sim.out

wave: sim
	gtkwave dump.vcd

lint:
	verilator --lint-only -Wall $(SRC)

clean:
	rm -f sim.out dump.vcd

.PHONY: sim wave lint clean
