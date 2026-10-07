# Lab files

One folder per lesson. Each folder has a `Makefile`; run `make` (or the target named in the lesson) from inside that folder.

| Folder | Lesson | Main targets |
|---|---|---|
| `lab01` | Setup and first simulation | `make`, `make wave`, `make lint` |
| `lab02` | Signals, numbers, operators | `make predict`, `make sim` |
| `lab03` | Combinational logic and hierarchy | `make sim`, `make adder` |
| `lab04` | always_comb, if, case | `make sim`, `make prio`, `make lint`, `make synth` |
| `lab05` | Flip-flops and counters | `make sim`, `make tick` |
| `lab06` | Finite state machines | `make sim`, `make traffic` |
| `lab07` | Parameters and generate | `make sim`, `make gray` |
| `lab08` | ALU | `make sim`, `make synth` |
| `lab09` | Memories and FIFOs | `make sim`, `make fifo` |
| `lab10` | Handshakes, pipelines, CDC | `make sim`, `make mac`, `make cdc` |
| `lab11` | Lint, synthesis, timing | `make adders`, `make popcount`, `make lint`, `make show` |
| `lab12` | Tiny Tapeout capstone | `make test`, `make lint`, `make synth` |

Starter files contain `TODO` comments, and their testbenches fail until you finish them. Reference answers are in each `solutions/` folder: try the exercise first, then compare.

To test a solution file instead of your own, compile it in place of the starter, for example from `lab05`:

```bash
iverilog -g2012 -o s.out solutions/tick_gen.sv tick_gen_tb.sv && vvp s.out
```

Generated files (`*.out`, `*.vcd`, `sim_build/`) can be deleted with `make clean`.
