# Lesson 12: Capstone, a Tiny Tapeout design

Tiny Tapeout puts hundreds of small designs from different people onto one shared chip, which makes manufacturing your own design affordable. This lesson packages a complete design in the Tiny Tapeout format, tests it with the same kind of test the official template uses, and walks through how your Verilog becomes a layout.

> [!NOTE]
> Before you start: finish Lessons 1 to 11. You also need Python 3 with cocotb (`pip install cocotb`); the Verification 101 track teaches cocotb properly, and here you only run a ready-made test. Plan on three hours, plus as long as you like for your own project. Lab files are in [`files/lab12`](../files/lab12/).

## What you will learn

- How a Tiny Tapeout chip is organized: tiles, the pin interface, and the shared multiplexer
- The rules a Tiny Tapeout design has to follow
- The template repository: `info.yaml`, `src/`, `test/`, `docs/`, and the GitHub Actions
- How the flow from RTL to layout runs, and where to look at the result
- How to extend a working design without breaking it

## Key ideas

### How Tiny Tapeout works

Each design gets one or more tiles, small rectangles of silicon (one tile is about 160 by 110 micrometers on SKY130). All the designs on a chip share the same input and output pads through a multiplexer, and an on-board controller selects which design is connected at any time. When your design is selected, its `ena` input is 1.

Every design has exactly this interface:

| Signal | Direction | Meaning |
|---|---|---|
| `ui_in[7:0]` | input | 8 dedicated inputs |
| `uo_out[7:0]` | output | 8 dedicated outputs |
| `uio_in[7:0]` | input | the input side of 8 bidirectional pins |
| `uio_out[7:0]` | output | the output side of the bidirectional pins |
| `uio_oe[7:0]` | output | 1 makes the matching `uio` pin an output |
| `clk` | input | clock (you pick the frequency in `info.yaml`) |
| `rst_n` | input | reset, active low |
| `ena` | input | 1 when your design is selected |

Shuttles (manufacturing runs) are offered on several open process technologies: SkyWater SKY130, GlobalFoundries GF180MCU, and IHP SG13G2. At the time this lesson was written (October 2026), SKY130 and GF180 shuttles were open for submissions. Check [tinytapeout.com/chips](https://tinytapeout.com/chips/) for current shuttles and deadlines.

### The rules

- The top module name must start with `tt_um_`, followed by something unique such as your GitHub name and a project name.
- Drive every output, including `uio_out` and `uio_oe`, even if you do not use them.
- No latches, no combinational loops, and no `initial` blocks in the design (they do not exist in hardware; use the reset).
- Use `` `default_nettype none `` and keep the source in plain Verilog unless you have checked that the flow supports the SystemVerilog features you use.
- Fit in the tiles you ask for. A 1x1 tile holds a few hundred standard cells comfortably.

### The template and its actions

You start from the official template, [ttsky-verilog-template](https://github.com/TinyTapeout/ttsky-verilog-template) for SKY130 shuttles, using GitHub's "Use this template" button. It contains:

| Path | What you change |
|---|---|
| `info.yaml` | project title, author, description, clock frequency, tile size, top module name, source file list, and a name for every pin |
| `src/project.v` | your design (add more files and list them in `info.yaml`) |
| `test/` | a cocotb testbench (`test.py`), a wrapper (`tb.v`), and a `Makefile` |
| `docs/info.md` | the text for your page in the chip's datasheet |

When you push to GitHub, the repository's Actions run automatically: `test` runs your cocotb tests, `gds` hardens the design into a layout with LibreLane, `docs` checks your datasheet page, and `fpga` builds an FPGA version for the demo board. Hardening runs the same flow you will study in PD 101:

![LibreLane ASIC flow diagram from RTL to GDS](https://librelane.readthedocs.io/en/latest/_images/asic-flow-diagram.webp "The RTL-to-GDS flow that runs in the Tiny Tapeout gds action: synthesis, floorplan, placement, clock tree, routing, and signoff checks.")

Credit: [LibreLane documentation, Newcomers' Tutorial](https://librelane.readthedocs.io/en/latest/getting_started/newcomers/index.html), Apache-2.0.

The result is a GDS file, the layout that goes to the factory. Here is a small multiplier hardened by LibreLane, the same kind of picture your `gds` action produces:

![Final layout of a small multiplier hardened by LibreLane](https://librelane.readthedocs.io/en/latest/_images/pm32-gds.webp "A finished layout: standard cells in rows, connected by several layers of metal.")

Credit: [LibreLane documentation, Newcomers' Tutorial](https://librelane.readthedocs.io/en/latest/getting_started/newcomers/index.html), Apache-2.0.

## Worked example: an 8-bit PWM generator

Pulse-width modulation (PWM) makes an output that is high for a chosen fraction of every period. It dims LEDs and drives motors. [`files/lab12/src/project.v`](../files/lab12/src/project.v) counts from 0 to 255 forever and keeps the output high while the count is below the duty value read from `ui_in`:

```verilog
always @(posedge clk) begin
    if (!rst_n) begin
        count <= 8'd0;
        duty  <= 8'd0;
        pwm   <= 1'b0;
    end else begin
        count <= count + 8'd1;
        if (count == 8'd255) duty <= ui_in;   // only change duty between periods
        pwm <= (count < duty);
    end
end

assign uo_out  = {count[7:2], ~pwm, pwm};
assign uio_out = 8'd0;
assign uio_oe  = 8'd0;
wire _unused = &{ena, uio_in, 1'b0};
```

Two details are worth copying into every Tiny Tapeout design:

- The duty value is captured once per period. If the switches change in the middle of a period, the output does not glitch.
- The last line ANDs together every unused input into a wire named `_unused`. It does nothing in hardware, but it tells the linter that leaving those inputs unconnected was deliberate.

```wavedrom
{ signal: [
  { name: "count", wave: "=.=.=.=.=.", data: ["0", "1", "...", "duty", "...255"] },
  { name: "pwm",   wave: "1.....0..." }
], head: { text: "one PWM period" } }
```

The test, [`files/lab12/test/test.py`](../files/lab12/test/test.py), sets several duty values and counts how many of 256 consecutive cycles have the output high:

```python
@cocotb.test()
async def duty_cycle(dut):
    await reset(dut)
    for duty in (0, 1, 64, 128, 200, 255):
        dut.ui_in.value = duty
        await ClockCycles(dut.clk, 300)          # let a new period pick up the value
        high = 0
        for _ in range(256):
            await RisingEdge(dut.clk)
            high += int(dut.uo_out.value) & 1
        assert high == duty, f"duty {duty}: counted {high} high cycles"
```

Any 256 consecutive cycles of a signal that repeats every 256 cycles contain exactly one full period, so the count must equal the duty value. Run it:

```bash
cd files/lab12
make test
```

```text
duty   0:   0 high cycles out of 256
duty   1:   1 high cycles out of 256
...
duty 255: 255 high cycles out of 256
** TESTS=2 PASS=2 FAIL=0 SKIP=0 **
```

[`files/lab12/info.yaml`](../files/lab12/info.yaml) shows how this design is described for Tiny Tapeout, including a name for every pin.

## Exercises

### Warm-up

1. Run `make test`, `make lint`, and `make synth` in `lab12`. How many cells does the design use?
2. With a 10 MHz clock, what is the PWM frequency? What duty value gives an output that is high about 25% of the time?
3. Why can this design never produce an output that is high 100% of the time? Change one line so `ui_in = 255` gives a constant high, and decide whether that is worth the change.

### Core

4. Add a breathing mode: when `uio_in[0]` is 1, ignore `ui_in` and sweep the duty value automatically, one step per period, up from 0 to 255 and back down. Write a cocotb test that measures several periods in a row and checks that the high count changes by at most one step each period.
5. Replace the inverted output on `uo_out[1]` with a second, independent PWM channel whose duty comes from `uio_in[7:0]` (leave all `uio` pins as inputs). Put the PWM logic in its own module and instantiate it twice. Update `info.yaml` pin names and the tests.
6. Make the design safe to use with any clock frequency by adding a prescaler: `uio_in[2:1]` selects whether the period counter advances every cycle, every 2nd, every 4th, or every 8th cycle. Test all four settings.

### Stretch

7. Start your own Tiny Tapeout project from the template. Some ideas that fit one tile: a UART transmitter that sends "SASi" when a button is pressed (use the [cocotbext-uart](https://github.com/alexforencich/cocotbext-uart) library in your test), a stopwatch that drives a seven-segment display from `uo_out`, or an electronic die built on the LFSR from Lesson 5. Get all four GitHub Actions to pass.
8. Harden your project on your own computer with the Tiny Tapeout tools, following the [local hardening guide](https://tinytapeout.com/guides/local-hardening/), and open the GDS in KLayout. Find your flip-flops in the layout.

## Solutions

<details>
<summary>Exercise 1: cell count</summary>

Yosys reports roughly 75 generic cells for the PWM design (the exact number depends on the version). After mapping to SKY130 cells in the real flow the count is similar, which is a small fraction of one tile.

</details>

<details>
<summary>Exercise 2: PWM frequency</summary>

One period is 256 cycles of 100 ns, so 25.6 microseconds, and the frequency is $10\,\text{MHz} / 256 \approx 39.1$ kHz. For 25%, set duty to 64.

</details>

<details>
<summary>Exercise 3: why never 100%</summary>

`count < duty` is false when `count` is 255, even for `duty = 255`, so the output is low for at least one cycle in 256. One fix: `pwm <= (duty == 8'd255) || (count < duty);`. Whether it is worth it depends on the use: for an LED, 255 out of 256 already looks fully on.

</details>

<details>
<summary>Exercise 4: breathing mode</summary>

```verilog
reg [7:0] sweep;        // automatic duty value
reg       sweep_up;     // direction
wire      breathe = uio_in[0];

// inside the clocked block, in the reset branch:
sweep <= 8'd0; sweep_up <= 1'b1;

// and in place of the old duty update:
if (count == 8'd255) begin
    if (sweep_up) begin
        if (sweep == 8'd254) sweep_up <= 1'b0;
        sweep <= sweep + 8'd1;
    end else begin
        if (sweep == 8'd1) sweep_up <= 1'b1;
        sweep <= sweep - 8'd1;
    end
    duty <= breathe ? sweep : ui_in;
end
```

Change the unused-input line to `wire _unused = &{ena, uio_in[7:1], 1'b0};` because `uio_in[0]` is used now. A test that sets `uio_in = 1`, waits a few periods, and records the high count of 12 consecutive periods sees `2, 3, 4, ...`: each period is one step brighter.

</details>

<details>
<summary>Exercise 5: two channels</summary>

```verilog
module pwm8 (
    input  wire       clk, rst_n,
    input  wire [7:0] count,      // shared period counter
    input  wire [7:0] duty_in,
    output reg        pwm
);
    reg [7:0] duty;
    always @(posedge clk) begin
        if (!rst_n) begin duty <= 8'd0; pwm <= 1'b0; end
        else begin
            if (count == 8'd255) duty <= duty_in;
            pwm <= (count < duty);
        end
    end
endmodule
```

Keep one counter in the top module, instantiate `pwm8` twice with `ui_in` and `uio_in` as the duty inputs, and drive `uo_out = {count[7:2], pwm_b, pwm_a}`. In `info.yaml`, rename `uo[1]` to `pwm_b` and give the `uio` pins names such as `duty_b[0]`.

</details>

<details>
<summary>Exercise 6: prescaler</summary>

Add a 3-bit free-running counter `pre`, and advance `count` only when the selected low bits of `pre` are all ones:

```verilog
reg [2:0] pre;
reg       step;
always @(*) begin
    case (uio_in[2:1])
        2'd0: step = 1'b1;
        2'd1: step = pre[0];
        2'd2: step = &pre[1:0];
        default: step = &pre[2:0];
    endcase
end
// in the clocked block: pre <= pre + 3'd1; and use "if (step)" around the count and duty logic
```

In the test, the high count over one full period becomes `duty` multiplied by 1, 2, 4, or 8 cycles, so measure over `256 * divide` cycles.

</details>

<details>
<summary>Exercise 7 and 8: your own project</summary>

There is no single answer. Before you submit, check: every output is driven, the cocotb tests cover reset and the main behavior, `make lint` is clean, the `gds` action passes, and `docs/info.md` explains how to use the design. Then ask in the club Discord for a review.

</details>

## Common mistakes

- A top module name that does not start with `tt_um_`, or does not match `top_module` in `info.yaml`.
- Leaving `uio_oe` undriven. Every output must have a value, even if it is zero.
- Logic that only works in simulation, such as `initial` blocks or delays like `#5`.
- Tests that never check anything. A test that only prints values passes even when the design is broken; use `assert`.

## Checklist

- [ ] `make test`, `make lint`, and `make synth` all pass in `lab12`
- [ ] You can explain every field in `info.yaml`
- [ ] Your extension (breathing, two channels, or prescaler) has a passing test
- [ ] You know which shuttle you would target and its deadline

## Further reading

- [Tiny Tapeout](https://tinytapeout.com/): the project home page, with guides and past chips.
- [Tiny Tapeout pinout specification](https://tinytapeout.com/specs/pinouts/): what each pin connects to on the demo board.
- [Tiny Tapeout local hardening guide](https://tinytapeout.com/guides/local-hardening/): run the `gds` flow on your own computer.
- [PD 101](https://stone-arch-silicon.github.io/PD_101/) and [Verification 101](https://stone-arch-silicon.github.io/Verification_101/): the next tracks, which go deeper into hardening and into testing.
