# Lesson 7: Parameters, generate, and SystemVerilog types

Good RTL is written once and reused at many sizes: an 8-bit adder and a 64-bit adder should come from the same source file. This lesson covers parameters, generate loops, and the SystemVerilog types (`enum`, `struct`, `package`) that make larger designs readable.

> [!NOTE]
> Before you start: finish Lesson 6. Plan on about two hours. Lab files are in [`files/lab07`](../files/lab07/).

## What you will learn

- `parameter` and `localparam`, and how to override them per instance
- `$clog2` for computing widths
- Generate loops and generate `if`, versus `for` loops inside `always` blocks
- Indexed part selects with `+:`
- Packed structs, enums, and packages, plus what open-source synthesis supports

## Key ideas

### Parameters

A parameter is a constant that the instantiating module can change:

```systemverilog
module counter_n #(
    parameter int WIDTH = 8,
    parameter int MAX   = (1 << WIDTH) - 1    // may depend on earlier parameters
) ( ... );
    localparam logic [WIDTH-1:0] LAST = WIDTH'(MAX);   // derived, cannot be overridden
```

```systemverilog
counter_n #(.WIDTH(4), .MAX(9)) cnt10 (...);   // a decade counter: 0 to 9
counter_n                       cnt8  (...);   // defaults: 8 bits, 0 to 255
```

Use `localparam` for values computed from parameters, so nobody can set them inconsistently.

### Computing widths with `$clog2`

`$clog2(n)` is the ceiling of $\log_2 n$: the number of bits needed to count from 0 to $n - 1$.

| n | `$clog2(n)` | Bits to hold 0 to n-1 |
|---|---|---|
| 2 | 1 | 1 |
| 5 | 3 | 3 |
| 8 | 3 | 3 |
| 60 | 6 | 6 |
| 1024 | 10 | 10 |

Careful: to hold the value $n$ itself (for example a count of items from 0 to $n$), you need `$clog2(n + 1)` bits.

### Generate loops

A generate loop stamps out copies of hardware at elaboration time, before simulation or synthesis starts:

```systemverilog
for (genvar i = 0; i < N; i++) begin : g_bit
    full_adder fa (.a(a[i]), .b(b[i]), .cin(c[i]), .sum(sum[i]), .cout(c[i+1]));
end
```

- `genvar` is a loop variable that only exists while the design is being built.
- The label `g_bit` names each copy (`g_bit[0].fa`, `g_bit[1].fa`, ...), which is how they appear in waveforms. Always label generate blocks.

A generate `if` chooses between two pieces of hardware based on a parameter:

```systemverilog
if (RIPPLE) begin : g_ripple
    adder_n #(.N(N)) u (.a(a), .b(b), .cin(1'b0), .sum(s[N-1:0]), .cout(s[N]));
end else begin : g_fast
    assign s = a + b;
end
```

A plain `for` loop inside `always_ff` or `always_comb` also unrolls into parallel hardware. It is the right tool for repeated assignments, such as shifting every bit of a register. Neither kind of loop runs over time in hardware; there is no loop counter on the chip.

The adder below is the SKY130 full adder cell. With `N = 32`, the generate loop above asks synthesis for 32 of them in a chain.

![Layout of the SKY130 full adder cell](https://skywater-pdk.readthedocs.io/en/main/_images/sky130_fd_sc_hd__fa_1.svg "sky130_fd_sc_hd__fa_1: a full adder as a single standard cell.")

Credit: [SkyWater SKY130 PDK documentation](https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/fa/README.html), Apache-2.0.

### Indexed part selects

`x[base +: width]` selects `width` bits starting at `base` and going up. The width must be a constant, but `base` may be a signal, which makes it the clean way to pick one field out of a packed bus:

```systemverilog
// N inputs of W bits each, packed side by side into one vector
assign y = d[sel*W +: W];
```

### Packed structs and enums

A packed struct groups named fields into one vector:

```systemverilog
typedef struct packed {
    logic [7:0] r;
    logic [7:0] g;
    logic [7:0] b;
} rgb_t;               // 24 bits; r is the most significant byte

rgb_t px;
assign px = {8'd255, 8'd128, 8'd0};
assign red_high = px.r[7];
```

Because it is packed, `px` can be assigned, compared, and registered like any 24-bit vector, while code reads `px.g` instead of `px[15:8]`.

### Packages and tool support

A package holds types, parameters, and functions that several files share:

```systemverilog
package color_pkg;
    typedef struct packed { logic [7:0] r, g, b; } rgb_t;
    localparam int MAX_BRIGHT = 255;
endpackage

module tb;
    import color_pkg::*;
    rgb_t px;
    ...
endmodule
```

Icarus Verilog and Verilator handle packages well. Yosys's built-in Verilog reader, used by most open-source synthesis flows, does not support every way of using them: for example a package type in a module's port list causes a syntax error. In this course, synthesizable modules share constants through parameters or a small `` `include `` file (you will see one in Lesson 8), and packages are used freely in testbenches. If you need full SystemVerilog in synthesis, look at the [yosys-slang](https://github.com/povik/yosys-slang) frontend.

## Worked example: one source, many sizes

[`files/lab07/param_tb.sv`](../files/lab07/param_tb.sv) builds four modules from three source files:

```systemverilog
adder_n #(.N(8))  add8  (.a(a8),  .b(b8),  .cin, .sum(s8),  .cout(c8));
adder_n #(.N(16)) add16 (.a(a16), .b(b16), .cin, .sum(s16), .cout(c16));
counter_n #(.WIDTH(4), .MAX(9)) cnt10 (.clk, .rst_n, .en, .count(dec), .wrap(dec_wrap));
shift_reg #(.N(8)) sr (.clk, .rst_n, .din, .q);
```

and checks 2,000 random additions at each width plus 35 steps of the decade counter:

```bash
cd files/lab07
make sim
```

```text
PASS: adders (8 and 16 bit) and decade counter correct
```

In the waveform, expand `add16` and notice the sixteen `g_bit[i]` instances that the generate loop created.

## Exercises

### Warm-up

1. Without running anything: what is `$clog2(1)`, `$clog2(3)`, `$clog2(64)`, `$clog2(65)`?
2. Instantiate `counter_n` as a counter that goes 0 to 59 (for seconds on a clock). What `WIDTH` do you pick, and why not more?
3. For `logic [31:0] x`, what does `x[8 +: 8]` select? What about `x[31 -: 4]`?

### Core

4. Complete the Gray code converters in [`files/lab07/bin2gray.sv`](../files/lab07/bin2gray.sv) and [`files/lab07/gray2bin.sv`](../files/lab07/gray2bin.sv). Both must work for any width `W`. Run `make gray` until it passes. Gray codes matter for crossing clock domains, which you will see in Lesson 10.
5. Write `muxn`, an N-to-1 multiplexer with parameters `N` and `W`. Pack the inputs into one vector `d[N*W-1:0]` and use an indexed part select. Test it with `N = 8, W = 8` and with `N = 5, W = 3`.
6. Write `adder_sel` with parameters `N` and `RIPPLE`. When `RIPPLE` is 1, build the adder from `adder_n`; when it is 0, use `a + b`. Use a generate `if`. Test both settings in one testbench.

### Stretch

7. Write a parameterized register file `regfile_p #(parameter int DEPTH, parameter int WIDTH)` with one write port and one read port, sized with `$clog2(DEPTH)`. What happens if `DEPTH` is not a power of two and the read address points past the end? Handle it, and document your choice.
8. Use the `rgb_t` struct to write `gray_pixel`: it takes an `rgb_t` and outputs the average of the three channels as 8 bits. Watch the width of the intermediate sum. Put the struct in a package for the testbench, and in an `` `include `` file for the design.

## Solutions

<details>
<summary>Exercise 1: clog2 values</summary>

`$clog2(1)` is 0, `$clog2(3)` is 2, `$clog2(64)` is 6, `$clog2(65)` is 7.

</details>

<details>
<summary>Exercise 2: a mod-60 counter</summary>

`counter_n #(.WIDTH(6), .MAX(59)) sec_cnt (...);` Six bits hold 0 to 63, which covers 59. More bits would only waste flip-flops, and `$clog2(60) = 6` agrees.

</details>

<details>
<summary>Exercise 3: indexed part selects</summary>

`x[8 +: 8]` is `x[15:8]`, the second byte. `x[31 -: 4]` is `x[31:28]`, the top four bits: `-:` goes downward from the base.

</details>

<details>
<summary>Exercise 4: Gray code converters</summary>

```systemverilog
// bin2gray
assign gray = bin ^ (bin >> 1);

// gray2bin
always_comb begin
    bin[W-1] = gray[W-1];
    for (int i = W - 2; i >= 0; i--) bin[i] = bin[i+1] ^ gray[i];
end
```

In `gray2bin`, each binary bit depends on the bit above it, so the loop must run from the top down. Full files: [`files/lab07/solutions/`](../files/lab07/solutions/).

</details>

<details>
<summary>Exercise 5: N-to-1 mux</summary>

```systemverilog
module muxn #(parameter int N = 8, parameter int W = 8) (
    input  wire  [N*W-1:0]       d,      // input k is d[k*W +: W]
    input  wire  [$clog2(N)-1:0] sel,
    output logic [W-1:0]         y
);
    assign y = d[sel*W +: W];
endmodule
```

With `N = 5`, `sel` is 3 bits and can reach 5, 6, or 7, which select bits past the end of `d`. Simulation returns `x` there. Either guarantee that `sel` stays below `N`, or add `assign y = (sel < N) ? d[sel*W +: W] : '0;`.

</details>

<details>
<summary>Exercise 6: generate if</summary>

```systemverilog
module adder_sel #(parameter int N = 8, parameter bit RIPPLE = 1) (
    input  wire [N-1:0] a, b,
    output wire [N:0]   s
);
    if (RIPPLE) begin : g_ripple
        adder_n #(.N(N)) u (.a(a), .b(b), .cin(1'b0), .sum(s[N-1:0]), .cout(s[N]));
    end else begin : g_fast
        assign s = a + b;
    end
endmodule
```

Lesson 11 measures how differently these two synthesize.

</details>

<details>
<summary>Exercise 7: parameterized register file</summary>

```systemverilog
module regfile_p #(parameter int DEPTH = 8, parameter int WIDTH = 8) (
    input  wire                     clk, we,
    input  wire [$clog2(DEPTH)-1:0] waddr, raddr,
    input  wire [WIDTH-1:0]         wdata,
    output logic [WIDTH-1:0]        rdata
);
    logic [WIDTH-1:0] regs [DEPTH];
    always_ff @(posedge clk) if (we && waddr < DEPTH) regs[waddr] <= wdata;
    // out-of-range reads return zero, by choice
    assign rdata = (raddr < DEPTH) ? regs[raddr] : '0;
endmodule
```

</details>

<details>
<summary>Exercise 8: gray_pixel</summary>

```systemverilog
// rgb_types.svh, included inside the module
typedef struct packed { logic [7:0] r, g, b; } rgb_t;

module gray_pixel (
    input  wire  [23:0] px_bits,
    output logic [7:0]  y
);
    `include "rgb_types.svh"
    rgb_t px;
    logic [9:0] sum;                 // 3 x 255 = 765 needs 10 bits
    assign px  = px_bits;
    assign sum = px.r + px.g + px.b;
    assign y   = 8'(sum / 3);        // a constant divisor; synthesis builds a small circuit
endmodule
```

Dividing by a constant 3 synthesizes to a fixed network of adders, which is fine at this size. A common shortcut is `(sum * 85) >> 8`, which is very close and cheaper.

</details>

## Common mistakes

- Unlabeled generate blocks. They get names like `genblk1`, which are hard to find in waveforms.
- Using `$clog2(N)` bits for a value that can equal `N`. A FIFO that holds 8 items needs 4 bits for its count, not 3.
- Assuming a `for` loop runs over many cycles. It unrolls into parallel hardware in a single cycle.
- Overriding a parameter by position, `counter_n #(4, 9)`. Use names; order is easy to get wrong.

## Checklist

- [ ] You can override parameters by name and explain `localparam`
- [ ] You can compute widths with `$clog2`, including the off-by-one case
- [ ] `make sim` and `make gray` pass in `lab07`
- [ ] You know which SystemVerilog features to keep out of synthesizable code for Yosys

## Further reading

- [HDLBits: More Verilog Features](https://hdlbits.01xz.net/wiki/Conditional): generate, loops, and reduction problems.
- [Gray code](https://en.wikipedia.org/wiki/Gray_code) on Wikipedia.
- [Yosys documentation: Verilog language support](https://yosyshq.readthedocs.io/projects/yosys/en/latest/using_yosys/verilog.html): which SystemVerilog features the built-in reader accepts.
- [Sutherland HDL papers](https://sutherland-hdl.com/papers.html): many short papers on SystemVerilog types for design.
