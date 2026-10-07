# Lesson 4: Procedural logic with always_comb, if, and case

When logic has many conditions, a list of `assign` statements becomes hard to read. An `always_comb` block lets you describe combinational logic step by step, with `if` and `case`. This lesson also covers the most common way that style goes wrong: the accidental latch.

> [!NOTE]
> Before you start: finish Lesson 3. Plan on about two hours. Lab files are in [`files/lab04`](../files/lab04/).

## What you will learn

- How `always_comb` describes combinational logic
- Blocking assignment (`=`) and why order matters inside a block
- `if` versus `case`, and when each one builds a priority chain
- `casez` and wildcard bits
- What a latch is, why you almost never want one, and how to avoid it

## Key ideas

### always_comb

```systemverilog
always_comb begin
    y = a;            // default
    if (sel) y = b;   // override
end
```

An `always_comb` block runs whenever any signal it reads changes, so the outputs always reflect the current inputs, exactly like `assign`. Inside the block, statements run in order from top to bottom, and each blocking assignment (`=`) takes effect immediately for the lines below it. Synthesis turns the whole block into combinational gates that produce the same final values.

The code above is a 2-to-1 mux. Writing a default first and then overriding it is the single most useful habit in this lesson.

Older Verilog code uses `always @*` (or `always @(a or b or sel)`) for the same purpose. `always_comb` is the SystemVerilog version: it also tells the tools that you intend combinational logic, so they can warn you when you accidentally build something else.

### if builds a priority chain

```systemverilog
always_comb begin
    grant = 2'd0;
    if      (req[3]) grant = 2'd3;
    else if (req[2]) grant = 2'd2;
    else if (req[1]) grant = 2'd1;
end
```

The first condition that is true wins, so `req[3]` has the highest priority. In hardware this becomes a chain of muxes, and the last condition passes through every one of them. Long chains are slow, which matters once you care about timing (Lesson 11).

### case builds a parallel choice

```systemverilog
always_comb begin
    case (op)
        2'd0:    y = a + b;
        2'd1:    y = a - b;
        2'd2:    y = a & b;
        default: y = a | b;
    endcase
end
```

When the case items do not overlap, there is no priority, and synthesis builds one wide mux. Always include a `default` branch. `casez` treats `?` (or `z`) bits in the case items as "don't care", which is handy for priority encoders:

```systemverilog
casez (req)
    4'b1???: grant = 2'd3;   // bit 3 set, ignore the others
    4'b01??: grant = 2'd2;
    4'b001?: grant = 2'd1;
    default: grant = 2'd0;
endcase
```

### The accidental latch

A latch is a memory element that is transparent while an enable is active and holds its value otherwise. If some path through your `always` block does not assign an output, the hardware has to remember the old value on that path, so synthesis builds a latch.

```systemverilog
always @* begin
    case (mode)
        2'd0: y = a;
        2'd1: y = b;
        2'd2: y = a & b;
        // mode 3: y is not assigned, so it must hold its old value
    endcase
end
```

Latches cause trouble on chips: they make timing analysis harder, they can glitch, and they usually mean the designer did not think about a case. The fix is always the same: assign every output on every path, most easily with a default at the top of the block.

Here is a real latch cell from the SKY130 library. Notice that it needs about as many transistors as a flip-flop, which is one more reason not to create them by accident.

![Transistor schematic of the SKY130 positive-enable latch cell](https://skywater-pdk.readthedocs.io/en/main/_images/sky130_fd_sc_hd__dlxtp.schematic.svg "sky130_fd_sc_hd__dlxtp: a latch that is transparent while its enable GATE is 1.")

Credit: [SkyWater SKY130 PDK documentation](https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/dlxtp/README.html), Apache-2.0.

## Worked example: a seven-segment decoder

A seven-segment display lights up to seven bars, named `a` to `g`, to draw a digit:

```text
  aaa
 f   b
  ggg
 e   c
  ddd
```

[`files/lab04/hex7seg.sv`](../files/lab04/hex7seg.sv) maps each hex digit to a 7-bit pattern `{g, f, e, d, c, b, a}` with a `case`:

```systemverilog
always_comb begin
    case (hex)
        4'h0: seg = 7'b0111111;
        4'h1: seg = 7'b0000110;
        4'h2: seg = 7'b1011011;
        // ... one line per digit ...
        4'hF: seg = 7'b1110001;
        default: seg = 7'b0000000;
    endcase
end
```

The testbench draws each digit in the terminal, so you can check the patterns by eye as well as against a reference table:

```bash
cd files/lab04
make sim
```

```text
digit 2
 ___
    |
 ---
|
 ___
...
PASS: all 16 digits correct
```

> [!WARNING]
> Icarus Verilog 12 sometimes prints `sorry: constant selects in always_* processes are not currently supported (all bits will be included).` for code like `if (req[7])` inside `always_comb`. It is a harmless limitation message, not an error in your design. Newer Icarus builds and Verilator do not print it.

## Exercises

### Warm-up

1. Rewrite the 4-input `if` priority chain above as a `casez`. Do both versions produce the same `grant` for every input?
2. In this block, what is `y` when `a = 1` and `b = 0`? Explain using "statements run in order".

   ```systemverilog
   always_comb begin
       y = 1'b0;
       if (a) y = 1'b1;
       if (b) y = 1'b0;
   end
   ```

3. Run `make lint` and `make synth` on [`files/lab04/latch_bug.sv`](../files/lab04/latch_bug.sv). Copy the line where Verilator names the problem and the line where Yosys says it inferred a latch.

### Core

4. Fix `latch_bug.sv` so that mode 3 outputs `a | b`, change `always @*` to `always_comb`, and confirm that both tools stop complaining.
5. Complete [`files/lab04/prio_enc.sv`](../files/lab04/prio_enc.sv), an 8-input priority encoder. Run `make prio` until all 256 patterns pass.
6. Write `onehot2bin`: input `oh` is 8 bits with exactly one bit set; output `idx` is that bit's position (3 bits). Use a `for` loop inside `always_comb`. What does your design output if more than one bit is set? Write the answer as a comment.

### Stretch

7. Change `hex7seg` so it can drive a common-anode display, where a 0 turns a segment on. Add a parameter `ACTIVE_LOW` (default 0) and use it so the same module works for both display types.
8. Write `bcd7seg`: like `hex7seg`, but for inputs 10 to 15 it shows a single dash (only segment `g`). Then write a testbench that checks it against `hex7seg` for inputs 0 to 9 and against the dash pattern for 10 to 15.

## Solutions

<details>
<summary>Exercise 1: casez priority</summary>

```systemverilog
always_comb begin
    casez (req)
        4'b1???: grant = 2'd3;
        4'b01??: grant = 2'd2;
        4'b001?: grant = 2'd1;
        default: grant = 2'd0;
    endcase
end
```

Yes, they match for all 16 inputs. Case items are checked in order, so overlapping `casez` items also have priority, just written more compactly.

</details>

<details>
<summary>Exercise 2: order inside always_comb</summary>

`y` is 1. The first line sets 0, the `if (a)` overrides it with 1, and `if (b)` does nothing because `b` is 0. If both `a` and `b` were 1, the last assignment would win and `y` would be 0.

</details>

<details>
<summary>Exercise 3: the tool messages</summary>

Verilator: `%Warning-CASEINCOMPLETE: latch_bug.sv:13:9: Case values incompletely covered (example pattern 0x3)`.

Yosys: `Latch inferred for signal '\latch_bug.\y' ...` and the cell count lists 8 latch cells (`$_DLATCH_N_` or similar), one per bit of `y`.

</details>

<details>
<summary>Exercise 4: fixing the latch</summary>

```systemverilog
always_comb begin
    y = 8'd0;                 // default: every path now assigns y
    case (mode)
        2'd0:    y = a;
        2'd1:    y = b;
        2'd2:    y = a & b;
        default: y = a | b;
    endcase
end
```

Either the default line at the top or the `default:` branch alone would remove the latch. Having both is a cheap habit that keeps it fixed when someone edits the case later. Full file: [`files/lab04/solutions/latch_bug.sv`](../files/lab04/solutions/latch_bug.sv).

</details>

<details>
<summary>Exercise 5: priority encoder</summary>

```systemverilog
always_comb begin
    idx   = 3'd0;
    valid = 1'b1;
    if      (req[7]) idx = 3'd7;
    else if (req[6]) idx = 3'd6;
    else if (req[5]) idx = 3'd5;
    else if (req[4]) idx = 3'd4;
    else if (req[3]) idx = 3'd3;
    else if (req[2]) idx = 3'd2;
    else if (req[1]) idx = 3'd1;
    else if (req[0]) idx = 3'd0;
    else             valid = 1'b0;
end
```

A shorter version uses a loop that walks upward, so the highest set bit is the last to assign `idx`:

```systemverilog
always_comb begin
    idx = 3'd0;
    for (int i = 0; i < 8; i++) if (req[i]) idx = 3'(i);
    valid = |req;
end
```

</details>

<details>
<summary>Exercise 6: one-hot to binary</summary>

```systemverilog
module onehot2bin (
    input  wire  [7:0] oh,
    output logic [2:0] idx
);
    // If several bits are set, the bit positions are ORed together,
    // so the output is meaningless. Callers must guarantee one-hot input.
    always_comb begin
        idx = 3'd0;
        for (int i = 0; i < 8; i++) if (oh[i]) idx = idx | 3'(i);
    end
endmodule
```

ORing positions instead of overwriting them builds less logic than a priority encoder, because there is no chain of conditions. That is the reason to use it when you know the input is one-hot.

</details>

<details>
<summary>Exercise 7: active-low option</summary>

```systemverilog
module hex7seg #(parameter bit ACTIVE_LOW = 1'b0) (
    input  wire  [3:0] hex,
    output logic [6:0] seg
);
    logic [6:0] on;           // 1 = segment lit
    always_comb begin
        case (hex)
            4'h0: on = 7'b0111111;
            // ... same table as before ...
            default: on = 7'b1110001;
        endcase
        seg = ACTIVE_LOW ? ~on : on;
    end
endmodule
```

</details>

<details>
<summary>Exercise 8: BCD with a dash</summary>

Copy the table for 0 to 9 and replace the rest with one default:

```systemverilog
always_comb begin
    case (bcd)
        4'd0: seg = 7'b0111111;
        // ... 4'd1 to 4'd9 as in hex7seg ...
        default: seg = 7'b1000000;   // only segment g: a dash
    endcase
end
```

</details>

## Common mistakes

- Missing a branch, or a signal that is assigned in some branches but not others. Result: a latch.
- Using nonblocking `<=` inside `always_comb`. It simulates strangely; use `=` for combinational logic and save `<=` for flip-flops (Lesson 5).
- Reading a variable before assigning it inside the same `always_comb`. That also implies memory. Assign first, then read.
- Writing `case` without `default`. Even when every value is listed today, a default protects you when someone widens the select signal later.

## Checklist

- [ ] You can explain why a missing branch creates a latch
- [ ] `hex7seg` passes, and you understand the bit order `{g, f, e, d, c, b, a}`
- [ ] Your priority encoder passes all 256 patterns
- [ ] `latch_bug.sv` is fixed and both Verilator and Yosys are quiet

## Further reading

- [HDLBits: Procedures](https://hdlbits.01xz.net/wiki/Alwaysblock1): `always` blocks, `if`, `case`, and avoiding latches, checked in your browser.
- [Verilator warning reference](https://verilator.org/guide/latest/warnings.html): what `CASEINCOMPLETE`, `LATCH`, and friends mean.
- [Seven-segment display](https://en.wikipedia.org/wiki/Seven-segment_display) on Wikipedia, including segment naming and common-anode wiring.
- [Cummings, "SystemVerilog's priority and unique: a solution to Verilog's full_case and parallel_case evil twins"](http://www.sunburst-design.com/papers/CummingsSNUG2005Israel_SystemVerilog_UniquePriority.pdf): what the `unique` and `priority` keywords add to `case`.
