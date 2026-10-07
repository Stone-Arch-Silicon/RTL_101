# Lesson 12 capstone
test:
	$(MAKE) -C test

lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME src/project.v

synth:
	yosys -p "read_verilog src/project.v; synth -top tt_um_sasi_pwm; stat"

clean:
	rm -rf test/sim_build test/results.xml test/tb.vcd test/__pycache__

.PHONY: test lint synth clean
