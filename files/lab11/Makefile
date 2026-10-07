# Lesson 11 lab
sim:
	iverilog -g2012 -Wall -o sim.out popcount_loop.sv popcount_tree.sv popcount_tb.sv
	vvp -n sim.out

# cell count and logic depth: `a + b` versus the ripple-carry adder from Lesson 7
adders:
	@echo "== add32 (a + b)"
	@yosys -q -p "read_verilog -sv add32.sv; synth -top add32; tee -o add32.stat stat; tee -o add32.ltp ltp -noff" >/dev/null
	@grep -E "Number of cells" add32.stat; grep -E "Longest topological path" add32.ltp
	@echo "== adder_n with N=32 (32 full adders in a chain)"
	@yosys -q -p "read_verilog -sv ../lab07/full_adder.sv ../lab07/adder_n.sv; chparam -set N 32 adder_n; synth -flatten -top adder_n; tee -o ripple.stat stat; tee -o ripple.ltp ltp -noff" >/dev/null
	@grep -E "Number of cells" ripple.stat; grep -E "Longest topological path" ripple.ltp

# the same measurement for the two popcount styles
popcount:
	@for t in popcount_loop popcount_tree; do \
	  echo "== $$t"; \
	  yosys -q -p "read_verilog -sv $$t.sv; synth -top $$t; tee -o $$t.stat stat; tee -o $$t.ltp ltp -noff" >/dev/null; \
	  grep -E "Number of cells" $$t.stat; grep -E "Longest topological path" $$t.ltp; \
	done

script:
	yosys -s synth.ys

# needs Graphviz (the `dot` program) installed
show:
	yosys -q -p "read_verilog -sv ../lab03/mux2.sv ../lab03/mux4.sv; hierarchy -top mux4; proc; flatten; opt; show -format svg -prefix mux4"
	@echo "wrote mux4.svg"

lint:
	-verilator --lint-only -Wall lint_me.sv

clean:
	rm -f *.out *.stat *.ltp *.svg *.dot dump.vcd

.PHONY: sim adders popcount script show lint clean
