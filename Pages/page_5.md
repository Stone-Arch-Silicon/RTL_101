# Lesson 5: Flip-flops, registers, and counters

Combinational logic forgets everything the moment its inputs change. To count, to wait, or to remember anything, hardware needs memory that updates on a clock. This lesson introduces the flip-flop, the clocked `always_ff` block, and the nonblocking assignment.

> [!NOTE]
> Before you start: finish Lesson 4. Plan on about two and a half hours. Lab files are in [`files/lab05`](../files/lab05/).

## What you will learn

- What a clock is, and how a D flip-flop behaves on a rising edge
- How to write registers with `always_ff` and nonblocking assignment (`<=`)
- Synchronous and asynchronous reset, and the `rst_n` naming convention
- Enables, counters, and pulse generators
- Setup time, hold time, and how they limit clock speed

## Key ideas

### The clock and the D flip-flop

A clock is a signal that toggles forever at a fixed rate. A clock at 100 MHz has a period of 10 ns. Almost every register in a digital design changes only at the clock's rising edge, the moment it goes from 0 to 1.

A D flip-flop has a data input `D`, a clock input, and an output `Q`. At each rising edge it copies `D` into `Q`, and it holds that value until the next edge, no matter what `D` does in between. A register is just a group of flip-flops sharing a clock.

```wavedrom
{ signal: [
  { name: "clk", wave: "p......" },
  { name: "D",   wave: "0.1..0." },
  { name: "Q",   wave: "0..1..0" }
], head: { text: "D flip-flop" } }
```

This is the SKY130 flip-flop cell that synthesis will use for every bit of every register you write. The second picture is its physical layout: the colored shapes are the layers that get manufactured.

![Symbol of the SKY130 D flip-flop cell](https://skywater-pdk.readthedocs.io/en/main/_images/sky130_fd_sc_hd__dfxtp.symbol.svg "sky130_fd_sc_hd__dfxtp: a positive-edge D flip-flop with input D, clock CLK, and output Q.")

Credit: [SkyWater SKY130 PDK documentation](https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/dfxtp/README.html), Apache-2.0.

![Layout of the SKY130 D flip-flop cell, drive strength 1](https://skywater-pdk.readthedocs.io/en/main/_images/sky130_fd_sc_hd__dfxtp_1.svg "Layout of sky130_fd_sc_hd__dfxtp_1. One flip-flop takes about five times the area of a two-input NAND gate.")

Credit: [SkyWater SKY130 PDK documentation](https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/dfxtp/README.html), Apache-2.0.

### always_ff and nonblocking assignment

```systemverilog
always_ff @(posedge clk) begin
    q <= d;
end
```

`always_ff @(posedge clk)` says: at every rising edge of `clk`, do this. The `<=` operator is a nonblocking assignment. All right-hand sides in the block are evaluated first, using the values from just before the edge, and only then do all the left-hand sides update together. That matches real flip-flops, which all sample at the same instant.

Compare a swap written both ways:

```systemverilog
always_ff @(posedge clk) begin   // nonblocking: a real swap
    a <= b;
    b <= a;
end

always @(posedge clk) begin      // blocking: both end up equal to the old d
    c = d;
    d = c;
end
```

The rule for this whole course: use `<=` in `always_ff`, use `=` in `always_comb`, and never mix them in one block.

### Reset

When power comes on, flip-flops hold random values. A reset input forces them to a known state.

- Synchronous reset is checked only at the clock edge: `if (!rst_n) q <= 0;` inside `always_ff @(posedge clk)`.
- Asynchronous reset acts immediately, even with no clock: `always_ff @(posedge clk or negedge rst_n)`.

The `_n` suffix means active low: the reset is applied while the signal is 0. That convention comes from board-level reset chips and is what Tiny Tapeout uses, so this course uses synchronous, active-low `rst_n` throughout. Not every register needs a reset. Control state (counters, valid bits, state machines) does; data registers that are always written before being read often do not.

### Enables and counters

An enable decides whether a register loads a new value on this edge:

```systemverilog
always_ff @(posedge clk) begin
    if (!rst_n)  count <= 8'd0;
    else if (en) count <= count + 8'd1;
end
```

When `en` is 0 there is no assignment, so the register keeps its value. In a flip-flop that is exactly what you want. (In `always_comb`, the same missing branch would make a latch.)

### Setup and hold times

A flip-flop needs `D` to be stable for a short time before the edge (setup time) and a short time after it (hold time). Between two registers, the signal leaves the first one a little after the edge (clock-to-Q delay), passes through some logic, and must arrive at the second one a setup time before the next edge. That sets the shortest clock period that works:

$$
T_{clk} \ge t_{clk \to q} + t_{logic} + t_{setup}
$$

and the fastest clock is $f_{max} = 1 / T_{clk,min}$. Simulation in this track ignores these delays. Static timing analysis checks them, and you will run it in PD 101.

## Worked example: an 8-bit counter

[`files/lab05/counter.sv`](../files/lab05/counter.sv) is the counter from the previous section. The testbench, [`files/lab05/counter_tb.sv`](../files/lab05/counter_tb.sv), introduces three patterns you will reuse in every clocked testbench:

```systemverilog
always #5 clk = ~clk;            // a free-running 10 ns clock

always @(posedge clk) begin      // a model that follows the same rules as the design
    if (!rst_n)  model <= 0;
    else if (en) model <= model + 1;
end

always @(negedge clk) begin      // check halfway between rising edges
    if (rst_n && count !== model) errors++;
end
```

Changing inputs and checking outputs on the falling edge keeps the testbench away from the rising edge, where the design is sampling. That avoids race conditions between testbench code and design code that run at the same simulation instant.

```bash
cd files/lab05
make sim
```

```text
PASS: counter matched the model for 300 cycles
```

Open the waveform with `make wave`. Find a cycle where `en` is 0 and confirm that `count` holds still on the next edge.

## Exercises

### Warm-up

1. Draw (on paper or in WaveDrom) `clk`, `en`, and `count` for six cycles after reset, with `en` pattern 1, 1, 0, 1, 0, 0. Mark the edges where `count` changes.
2. In the swap example above, what values do `a`, `b`, `c`, and `d` hold after one edge if they started at `a=1, b=2, c=1, d=2`?
3. A path has clock-to-Q of 0.3 ns, logic delay of 4.2 ns, and setup time of 0.1 ns. What is the fastest clock frequency it allows?

### Core

4. Complete [`files/lab05/tick_gen.sv`](../files/lab05/tick_gen.sv). It must produce a one-cycle pulse every `N` cycles. The comments describe exactly when the pulse is high. Run `make tick` until it passes for both `N = 5` and `N = 1000`.
5. Write `updown`: an 8-bit counter with inputs `en`, `up`, `load`, and `d[7:0]`. Priority is reset, then load (copy `d`), then count (up when `up` is 1, down when it is 0, only when `en` is 1). Write a clocked testbench with a model, like `counter_tb.sv`.
6. Rewrite `counter.sv` with an asynchronous reset. In the testbench, pull `rst_n` low halfway between two clock edges and check that `count` clears immediately instead of at the next edge.

### Stretch

7. A linear feedback shift register (LFSR) is a shift register whose new bit is an XOR of some of its own bits. It produces a long, pseudo-random sequence with almost no logic. Build an 8-bit LFSR that shifts left and feeds back `q[7] ^ q[5] ^ q[4] ^ q[3]`, reset to `8'h01`. Measure in simulation how many cycles it takes to return to `8'h01`.
8. Mechanical buttons bounce: when pressed, the signal flips between 0 and 1 for a few milliseconds. Write `debounce` with a parameter `STABLE` that only changes its output after the input has held the same value for `STABLE` consecutive cycles. Test it with a bouncy input made from `$urandom`.

## Solutions

<details>
<summary>Exercise 1: counter waveform</summary>

```wavedrom
{ signal: [
  { name: "clk",   wave: "p......" },
  { name: "en",    wave: "1.010.." },
  { name: "count", wave: "===.=..", data: ["0", "1", "2", "3"] }
] }
```

Read each column as "the value just after that rising edge". At every edge, `count` adds the `en` value from the column before it: 0, 1, 2, then holds, then 3, then holds.

</details>

<details>
<summary>Exercise 2: swap results</summary>

After one edge: `a=2, b=1` (a true swap) and `c=2, d=2`. In the blocking version, `c = d` makes `c` equal 2 before `d = c` runs, so `d` gets the new `c`, which is also 2.

</details>

<details>
<summary>Exercise 3: maximum frequency</summary>

$T = 0.3 + 4.2 + 0.1 = 4.6$ ns, so $f_{max} = 1 / 4.6\,\text{ns} \approx 217$ MHz.

</details>

<details>
<summary>Exercise 4: tick generator</summary>

```systemverilog
localparam int W = (N > 1) ? $clog2(N) : 1;
logic [W-1:0] cnt;

always_ff @(posedge clk) begin
    if (!rst_n)                cnt <= '0;
    else if (cnt == W'(N - 1)) cnt <= '0;
    else                       cnt <= cnt + 1'b1;
end

assign tick = rst_n && (cnt == W'(N - 1));
```

`'0` means "all zeros at whatever width is needed". `W'(N - 1)` converts the integer to `W` bits so the comparison has matching widths. Full file: [`files/lab05/solutions/tick_gen.sv`](../files/lab05/solutions/tick_gen.sv).

</details>

<details>
<summary>Exercise 5: up/down counter with load</summary>

```systemverilog
module updown (
    input  wire        clk, rst_n, load, en, up,
    input  wire  [7:0] d,
    output logic [7:0] q
);
    always_ff @(posedge clk) begin
        if (!rst_n)    q <= 8'd0;
        else if (load) q <= d;
        else if (en)   q <= up ? q + 8'd1 : q - 8'd1;
    end
endmodule
```

The order of the `if` branches is the priority the exercise asked for.

</details>

<details>
<summary>Exercise 6: asynchronous reset</summary>

```systemverilog
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)  count <= 8'd0;
    else if (en) count <= count + 8'd1;
end
```

The reset must be listed in the sensitivity list and tested first. In the testbench, use something like `@(posedge clk); #3 rst_n = 0; #1 if (count !== 0) errors++;` to check that the clear happens 1 ns after the reset falls, without waiting for a clock edge.

</details>

<details>
<summary>Exercise 7: LFSR</summary>

```systemverilog
module lfsr8 (
    input  wire        clk, rst_n,
    output logic [7:0] q
);
    always_ff @(posedge clk) begin
        if (!rst_n) q <= 8'h01;
        else        q <= {q[6:0], q[7] ^ q[5] ^ q[4] ^ q[3]};
    end
endmodule
```

It returns to `8'h01` after 255 cycles: it visits every nonzero 8-bit value exactly once. That is the most possible, because the all-zero state would never leave itself. These tap positions come from a "maximal length" polynomial, $x^8 + x^6 + x^5 + x^4 + 1$.

</details>

<details>
<summary>Exercise 8: debouncer</summary>

```systemverilog
module debounce #(parameter int STABLE = 1000) (
    input  wire  clk, rst_n, noisy,
    output logic clean
);
    localparam int CW = $clog2(STABLE + 1);
    logic [CW-1:0] cnt;
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            clean <= 1'b0;
            cnt   <= '0;
        end else if (noisy == clean) begin
            cnt <= '0;                         // input agrees with output: nothing to do
        end else if (cnt == CW'(STABLE - 1)) begin
            clean <= noisy;                    // disagreed for STABLE cycles in a row
            cnt   <= '0;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule
```

A real input pin also needs a synchronizer before this logic, because the button is not related to your clock. Lesson 10 explains why.

</details>

## Common mistakes

- Using `=` in `always_ff`. With more than one register in a block, the result depends on statement order, and simulation can disagree with the synthesized hardware.
- Assigning the same register from two different `always_ff` blocks. Each register must have exactly one block that drives it.
- Forgetting the reset in the testbench. Without it, registers start as `x` and every check fails.
- Changing testbench inputs exactly at the rising edge. Change them on the falling edge, or a little after the rising edge.

## Checklist

- [ ] You can explain the difference between `<=` and `=` with the swap example
- [ ] `counter_tb` passes and you can find an enable-off cycle in the waveform
- [ ] `tick_gen` passes for both values of `N`
- [ ] You can compute $f_{max}$ from clock-to-Q, logic, and setup delays

## Further reading

- [Cummings, "Nonblocking Assignments in Verilog Synthesis, Coding Styles That Kill!"](http://www.sunburst-design.com/papers/CummingsSNUG2000SJ_NBA.pdf): the classic paper behind the `<=` rule.
- [HDLBits: Latches and Flip-Flops](https://hdlbits.01xz.net/wiki/Dff) and [Counters](https://hdlbits.01xz.net/wiki/Count15): many short practice problems.
- [Linear-feedback shift register](https://en.wikipedia.org/wiki/Linear-feedback_shift_register) on Wikipedia, with tables of maximal-length taps.
- [Flip-flop (electronics)](https://en.wikipedia.org/wiki/Flip-flop_(electronics)) on Wikipedia, including setup and hold timing.
