# RTL 101: digital design with Verilog and SystemVerilog

A Stone Arch Silicon training track. Twelve lessons take you from your first simulation to a design packaged for a real chip through Tiny Tapeout. Every lesson has short theory, a worked example, and exercises that ramp from warm-up to stretch, with tested lab files and solutions.

Read it online: <https://stone-arch-silicon.github.io/RTL_101/>

Status: first complete draft. Every lab in `files/` has been run with Icarus Verilog, Verilator, and Yosys. Reports and pull requests are welcome.

## Start here

1. Read [Lesson 1](Pages/page_1.md) and install OSS CAD Suite.
2. Clone this repository and run `make` in `files/lab01`.
3. Work through the lessons in order. Each one says which earlier lessons it needs.
4. Finish with [Lesson 12](Pages/page_12.md), a design in the Tiny Tapeout format.

You should be comfortable with a terminal (Linux, macOS, or WSL on Windows). No Verilog experience is needed.

## Tools

Everything is open source. There is no Vivado or other commercial tool anywhere in the track.

| Tool | Used for |
|---|---|
| [Icarus Verilog](https://steveicarus.github.io/iverilog/) | simulation |
| [Verilator](https://verilator.org/) | linting (and fast simulation) |
| [Yosys](https://yosyshq.net/yosys/) | synthesis, cell counts, logic depth |
| [GTKWave](https://gtkwave.github.io/gtkwave/) or [Surfer](https://surfer-project.org/) | waveforms |
| [cocotb](https://www.cocotb.org/) | the Tiny Tapeout test in Lesson 12 |

All of them come in one download, [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build). The [IIC-OSIC-TOOLS](https://github.com/iic-jku/IIC-OSIC-TOOLS) container also works.

## Course map

| Lesson | Topic | You build |
|---|---|---|
| [1](Pages/page_1.md) | Setup and your first simulation | half adder and full adder with self-checking testbenches |
| [2](Pages/page_2.md) | Signals, numbers, and operators | bit tricks, two's complement, saturating add |
| [3](Pages/page_3.md) | Combinational logic and hierarchy | muxes, decoders, a 4-bit ripple adder |
| [4](Pages/page_4.md) | always_comb, if, and case | seven-segment decoder, priority encoder, latch fix |
| [5](Pages/page_5.md) | Flip-flops, registers, and counters | counters, tick generator, LFSR, debouncer |
| [6](Pages/page_6.md) | Finite state machines | sequence detector, traffic light, vending machine |
| [7](Pages/page_7.md) | Parameters, generate, SystemVerilog types | N-bit adder, Gray code converters, N-to-1 mux |
| [8](Pages/page_8.md) | Arithmetic datapaths | 8-bit ALU with flags, carry lookahead, exhaustive test |
| [9](Pages/page_9.md) | Memories and FIFOs | register file, synchronous FIFO, stack |
| [10](Pages/page_10.md) | Handshakes, pipelines, clock crossing | skid buffer, pipelined MAC, pulse synchronizer |
| [11](Pages/page_11.md) | Lint, synthesis, and timing | lint cleanup, adder and popcount comparisons |
| [12](Pages/page_12.md) | Capstone: Tiny Tapeout | PWM generator with cocotb tests and `info.yaml` |

## Repository guide

| Path | Purpose |
|---|---|
| `Pages/page_N.md` | the lessons, one Markdown file each |
| `Pages/TEMPLATE.md` | starting point for a new lesson, showing every supported feature |
| `files/labNN/` | starter code, testbenches, Makefiles, and `solutions/` for each lesson |
| `index.html`, `app.js`, `style.css` | the course website |
| `.nojekyll` | tells GitHub Pages to serve the Markdown files as they are |

## How the website works

`index.html` loads `app.js`, which fetches `Pages/page_1.md`, `Pages/page_2.md`, and so on until a number is missing, then renders each one in the browser with its own Markdown parser. Besides normal Markdown (headings, lists, tables, code, links, images), the parser understands:

- images on their own line, with a caption in quotes and a `Credit:` line underneath, shown as a captioned figure
- LaTeX math between `$` signs, rendered with KaTeX
- `mermaid` and `wavedrom` code blocks, drawn as diagrams
- GitHub callouts such as `> [!NOTE]` and `> [!WARNING]`
- `<details>` and `<summary>` for collapsible solutions
- syntax highlighting for SystemVerilog, Python, Tcl, shell, and more

The libraries load from the jsDelivr CDN only on pages that use them. To edit the course name or links, change the `CONFIG` block at the top of `app.js`.

To preview the site on your own computer, serve the repository root and open <http://localhost:8000>:

```bash
python3 -m http.server 8000
```

## Contributing

Pick a lesson or an exercise, make one focused change, and say how you checked it. Keep lesson file names stable so links keep working. When you add code, add or update a self-checking testbench and run it. Write in plain prose, define new terms the first time they appear, and order exercises from easy to hard. Add yourself under "Authors and reviewers" only with your agreement.

## Image credits

Lesson images are linked from their original sites and keep their own licenses, which are named under each image. They come from the [SkyWater SKY130 PDK documentation](https://skywater-pdk.readthedocs.io/) (Apache-2.0), the [Yosys documentation](https://yosyshq.readthedocs.io/) (ISC), the [OpenROAD-flow-scripts documentation](https://openroad-flow-scripts.readthedocs.io/) (BSD-3-Clause), the [LibreLane documentation](https://librelane.readthedocs.io/) (Apache-2.0), and the [Surfer project](https://surfer-project.org/).

## Related Stone Arch Silicon tracks

- [ASIC 101](https://stone-arch-silicon.github.io/ASIC_101/): one 8-bit ALU from RTL to GDSII
- [Verification 101](https://stone-arch-silicon.github.io/Verification_101/): testbenches, cocotb, assertions, formal, and UVM concepts
- [PD 101](https://stone-arch-silicon.github.io/PD_101/): physical design with LibreLane and SKY130
- [Analog 101](https://stone-arch-silicon.github.io/Analog_101/): analog circuit design and layout with open tools
- [Club website](https://stone-arch-silicon.github.io/stone-arch-silicon/)
