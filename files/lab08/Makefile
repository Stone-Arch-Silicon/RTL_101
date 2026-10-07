# Lesson 8 lab (the exhaustive test takes a few seconds)
sim:
	iverilog -g2012 -Wall -o sim.out alu8.sv alu8_tb.sv
	vvp -n sim.out

lint:
	verilator --lint-only -Wall alu8.sv

synth:
	yosys -p "read_verilog -sv alu8.sv; synth -top alu8; stat"

clean:
	rm -f *.out dump.vcd

.PHONY: sim lint synth clean
