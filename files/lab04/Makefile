# Lesson 4 lab
sim:
	iverilog -g2012 -Wall -o sim.out hex7seg.sv hex7seg_tb.sv
	vvp -n sim.out

prio:
	iverilog -g2012 -Wall -o prio.out prio_enc.sv prio_enc_tb.sv
	vvp -n prio.out

lint:
	-verilator --lint-only -Wall latch_bug.sv

synth:
	yosys -p "read_verilog -sv latch_bug.sv; synth -top latch_bug; stat" | grep -E "Latch inferred|DLATCH|Number of cells"

clean:
	rm -f *.out dump.vcd

.PHONY: sim prio lint synth clean
