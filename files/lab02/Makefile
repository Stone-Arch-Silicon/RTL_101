# Lesson 2 lab
predict:
	iverilog -g2012 -o predict.out predict_tb.sv
	vvp -n predict.out

sim: bit_tricks.sv bit_tricks_tb.sv
	iverilog -g2012 -Wall -o sim.out bit_tricks.sv bit_tricks_tb.sv
	vvp -n sim.out

lint:
	verilator --lint-only -Wall bit_tricks.sv

clean:
	rm -f *.out dump.vcd

.PHONY: predict sim lint clean
