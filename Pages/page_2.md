# Lesson 2: Signals, numbers, and operators

Hardware works on groups of bits. This lesson covers how Verilog writes numbers, how negative numbers are stored, and what every operator does, including the width rules that surprise almost everyone the first time.

> [!NOTE]
> Before you start: finish Lesson 1. Plan on about two hours. Lab files are in [`files/lab02`](../files/lab02/).

## What you will learn

- Vectors, bit selects, and part selects
- How to write sized number literals in binary, decimal, and hexadecimal
- The four values a Verilog bit can have: 0, 1, x, and z
- Two's complement, the way hardware stores negative numbers
- Every common operator, and how Verilog decides the width of a result

## Key ideas

### Bits are voltages

Inside a chip, a bit is a voltage on a wire: near 0 V means 0, and near the supply voltage (1.8 V on the SKY130 process this course uses later) means 1. Logic gates are small groups of transistors that compute one voltage from others. The NOT gate below is a real cell from the SKY130 standard cell library: one transistor pulls the output up, the other pulls it down.

![Transistor schematic of the SKY130 inverter standard cell](https://skywater-pdk.readthedocs.io/en/main/_images/sky130_fd_sc_hd__inv.schematic.svg "The sky130_fd_sc_hd__inv cell: a PMOS transistor on top and an NMOS transistor on the bottom.")

Credit: [SkyWater SKY130 PDK documentation](https://skywater-pdk.readthedocs.io/en/main/contents/libraries/sky130_fd_sc_hd/cells/inv/README.html), Apache-2.0.

In RTL you almost never think about voltages. You think about bits, and groups of bits called vectors.

### Vectors and selects

```systemverilog
logic [7:0] data;      // 8 bits: data[7] is the most significant bit (MSB), data[0] the least (LSB)
logic [3:0] nib;

assign nib = data[7:4];   // part select: the upper four bits
assign top = data[7];     // bit select: one bit
```

The range `[7:0]` is written MSB first. A part select must keep the same direction, so `data[4:7]` is an error when `data` is declared `[7:0]`.

`logic` is the SystemVerilog type for a signal that you drive from exactly one place. Older Verilog splits it into `wire` (driven by `assign` or a port) and `reg` (driven inside an `always` block). The name `reg` is misleading because it does not mean "register", which is one reason `logic` exists.

### Number literals

A literal has the form `width'base value`:

| Literal | Width | Value |
|---|---|---|
| `4'b1010` | 4 bits | binary 1010, which is 10 |
| `8'hFF` | 8 bits | hexadecimal FF, which is 255 |
| `12'd100` | 12 bits | decimal 100 |
| `16'b0000_1111_0000_1111` | 16 bits | underscores are only for readability |
| `8'sd3` | 8 bits | the `s` marks it as signed |
| `100` | 32 bits | an unsized literal is 32 bits and signed |

Always give literals a width in RTL. Unsized literals are 32 bits wide, and that can widen expressions in ways you did not intend.

### Four-state values

Each bit holds one of four values:

- `0` and `1`: the normal values
- `x`: unknown. The simulator cannot tell whether the bit is 0 or 1, for example a register before reset, or two drivers fighting.
- `z`: high impedance, meaning nothing is driving the wire at all

Real hardware only has 0 and 1. `x` exists so that simulation can warn you when a value depends on something you never set. An `x` showing up in a waveform is almost always a bug worth chasing.

### Two's complement

With $n$ bits you can store $2^n$ patterns. Unsigned numbers use them for $0$ to $2^n - 1$. Signed numbers use two's complement, where the top bit counts as a negative weight:

$$
\text{value} = -b_{n-1}\,2^{n-1} + \sum_{i=0}^{n-2} b_i\,2^i
$$

For 8 bits the range is $-128$ to $127$. Examples:

| Bits | Unsigned | Signed |
|---|---|---|
| `0000_0011` | 3 | 3 |
| `0111_1111` | 127 | 127 |
| `1000_0000` | 128 | -128 |
| `1111_1101` | 253 | -3 |
| `1111_1111` | 255 | -1 |

To negate a number, invert every bit and add one: $-x = \bar{x} + 1$. The same adder works for signed and unsigned numbers, which is why every processor uses this format.

### Operators

| Group | Operators | Notes |
|---|---|---|
| Arithmetic | `+ - * / %` | `/` and `%` are large in hardware; avoid them in RTL unless dividing by a power of two |
| Bitwise | `& \| ^ ~` | act on each bit position separately |
| Reduction | `&x \|x ^x` | combine all bits of one vector into one bit (AND of all, OR of all, XOR of all) |
| Logical | `&& \|\| !` | treat a whole vector as true (nonzero) or false (zero), result is one bit |
| Compare | `== != < > <= >=` | result is one bit; may be `x` if inputs have `x` |
| Case equality | `=== !==` | also compares `x` and `z` exactly; result is always 0 or 1; testbenches only |
| Shift | `<< >> <<< >>>` | `>>>` shifts in copies of the sign bit when the operand is signed |
| Concatenate | `{a, b}` | glue vectors together, `a` on the left (most significant) |
| Replicate | `{4{a}}` | `a` repeated four times |
| Conditional | `s ? x : y` | `x` when `s` is 1, `y` when `s` is 0; this is a multiplexer |

### How wide is the result?

Verilog sizes an expression by looking at the widths of its operands and of the place the result is stored, and uses the widest. Then:

- If the result is stored into something narrower, the top bits are thrown away (truncation).
- If an operand is narrower than the expression, it is extended: with zeros if unsigned, with copies of its sign bit if the whole expression is signed.

So `4'b1010 + 4'b0111` printed on its own is computed in 4 bits and wraps to `0001`, but the same sum stored into a 5-bit variable is computed in 5 bits and gives `10001`. One unsigned operand makes the whole expression unsigned, which is a common source of signed math bugs. Use `$signed(x)` and `$unsigned(x)` to be explicit.

## Worked example: predict, then run

[`files/lab02/predict_tb.sv`](../files/lab02/predict_tb.sv) prints twelve expressions. Before you run it, write down what you think each line prints. Then run:

```bash
cd files/lab02
make predict
```

The output and the reason for each line:

| Line | Expression | Prints | Why |
|---|---|---|---|
| 1 | `4'b1010 + 4'b0111` | `0001` | 10 + 7 = 17 does not fit in 4 bits; the carry is lost |
| 2 | same sum into `logic [4:0]` | `10001 (17)` | the 5-bit target makes the addition 5 bits wide |
| 3 | `8'd200 + 8'd100` into 8 bits | `44` | 300 minus 256 |
| 4 | `-8'sd3` | `11111101` | invert 00000011, add one |
| 5 | `8'hF0 >> 2` (unsigned) | `3c` | zeros shift in from the left |
| 6 | `8'shF0 >>> 2` (signed) | `fc` | copies of the sign bit (1) shift in |
| 7 | `&`, `\|`, `^` of `4'b1011` | `&=0 \|=1 ^=1` | not all ones; at least one 1; three 1s is odd |
| 8 | `{2'b10, {3{2'b01}}}` | `10010101` | `10` followed by `01` three times |
| 9 | `4'b1x01 & 4'b0101` | `0x01` | `x & 1` is unknown, but `x & 0` is surely 0 |
| 10 | `==` and `===` with an `x` bit | `x 0` | `==` cannot decide, `===` compares exactly |
| 11 | `8'hFF < 1` unsigned, then signed | `0 1` | 255 is not below 1, but -1 is |
| 12 | `u8[7:4]` and `u8[0]` of `1100_0101` | `1100 1` | part select and bit select |

## Exercises

### Warm-up

1. Convert by hand, then check one of them in a quick testbench: the 8-bit two's complement patterns for $-1$, $-100$, and $-128$; and the signed values of `8'b1000_0001` and `8'b1110_0000`.
2. What do these evaluate to? `{4{1'b1}}`, `|8'b0000_0000`, `^8'b1111_0000`, `3'b101 << 1` (as a 3-bit result).
3. How many bits do you need to store the sum of two 8-bit unsigned numbers without losing anything? The product of two 8-bit numbers?

### Core

4. Complete [`files/lab02/bit_tricks.sv`](../files/lab02/bit_tricks.sv). Each output has one line of `assign`, using only the operators from this lesson. Run `make sim` until it prints PASS for all 256 inputs.
5. Write a module `sat_add8` with inputs `a`, `b` (8-bit unsigned) and output `y` that saturates: if the true sum is above 255, `y` is 255 instead of wrapping around. Use a 9-bit intermediate sum. Test it with a loop over all 65,536 input pairs.
6. A colleague writes `assign avg = (a + b) >> 1;` with 8-bit `a`, `b`, and `avg`. Show an input pair where the answer is wrong, and fix the line.

### Stretch

7. Write `abs8`: input `x` is an 8-bit signed number, output `y` is its absolute value as an 8-bit unsigned number. What should happen for $-128$? Write your choice as a comment.
8. Let `s8` be the 8-bit sum `a + b`. Using only bit selects and the operators `&`, `|`, `~`, `^`, and `==`, write an expression that is 1 exactly when the addition overflows as signed numbers (the true answer is above 127 or below $-128$). Hint: look at the sign bits of `a`, `b`, and `s8`.

## Solutions

<details>
<summary>Exercise 1: two's complement by hand</summary>

- $-1$: `1111_1111`
- $-100$: 100 is `0110_0100`; invert to `1001_1011`; add one: `1001_1100`
- $-128$: `1000_0000`
- `1000_0001` is $-128 + 1 = -127$
- `1110_0000` is $-128 + 64 + 32 = -32$

</details>

<details>
<summary>Exercise 2: operator results</summary>

`{4{1'b1}}` is `1111`. `|8'b0` is `0`. `^8'b1111_0000` is `0` (four ones is even). `3'b101 << 1` in 3 bits is `010`; the top 1 falls off.

</details>

<details>
<summary>Exercise 3: result widths</summary>

A sum of two $n$-bit numbers needs $n + 1$ bits (9 here): the largest is $255 + 255 = 510$. A product needs $2n$ bits (16 here): $255 \times 255 = 65025 < 65536$.

</details>

<details>
<summary>Exercise 4: bit_tricks</summary>

```systemverilog
assign is_neg   = x[7];
assign negated  = ~x + 8'd1;
assign parity   = ^x;
assign all_ones = &x;
assign swapped  = {x[3:0], x[7:4]};
assign sext     = {{8{x[7]}}, x};
```

Full file: [`files/lab02/solutions/bit_tricks.sv`](../files/lab02/solutions/bit_tricks.sv). Run it with `iverilog -g2012 -o s.out solutions/bit_tricks.sv bit_tricks_tb.sv && vvp s.out`.

</details>

<details>
<summary>Exercise 5: saturating add</summary>

```systemverilog
module sat_add8 (
    input  wire  [7:0] a, b,
    output logic [7:0] y
);
    logic [8:0] s;
    assign s = {1'b0, a} + {1'b0, b};     // 9 bits, nothing lost
    assign y = s[8] ? 8'hFF : s[7:0];     // carry out means "too big"
endmodule
```

</details>

<details>
<summary>Exercise 6: average of two numbers</summary>

With `a = 200` and `b = 100`, the sum is computed in 8 bits because every operand and the target are 8 bits wide. It wraps to 44, and 44 shifted right is 22 instead of 150. Widen the sum before shifting:

```systemverilog
logic [8:0] sum9;
assign sum9 = a + b;          // 9-bit target, so the add is 9 bits wide
assign avg  = sum9[8:1];      // divide by two by dropping the lowest bit
```

</details>

<details>
<summary>Exercise 7: absolute value</summary>

```systemverilog
module abs8 (
    input  wire  [7:0] x,     // signed
    output logic [7:0] y      // unsigned magnitude
);
    // -128 has no positive 8-bit signed partner, but as an unsigned 8-bit
    // number its magnitude 128 fits, so ~x + 1 = 1000_0000 = 128 is correct here.
    assign y = x[7] ? (~x + 8'd1) : x;
endmodule
```

</details>

<details>
<summary>Exercise 8: signed overflow</summary>

Overflow happens when both inputs have the same sign and the result has the other sign:

```systemverilog
assign s8  = a + b;                                   // the 8-bit sum
assign ovf = (a[7] == b[7]) & (s8[7] != a[7]);
```

Equivalently, `ovf = (a[7] & b[7] & ~s8[7]) | (~a[7] & ~b[7] & s8[7])`. You will use this rule again in the Lesson 8 ALU.

</details>

## Common mistakes

- Mixing signed and unsigned operands. If any operand is unsigned, the whole expression is unsigned, and `<` gives the unsigned answer.
- Forgetting that the target width matters. `y = a + b` and `{c, y} = a + b` compute different widths.
- Writing `!x` when you mean `~x`. For a vector, `!x` is a single bit (is `x` zero?), while `~x` inverts every bit.
- Comparing with `x` using `==`. The result is `x`, and an `if` treats `x` as false.

## Checklist

- [ ] You can convert between binary, hexadecimal, and decimal for 8-bit values
- [ ] You can negate a number in two's complement by hand
- [ ] Your predictions for `predict_tb.sv` matched, or you understand each difference
- [ ] `bit_tricks` passes all 256 inputs

## Further reading

- [Two's complement](https://en.wikipedia.org/wiki/Two%27s_complement) on Wikipedia, with a good table of examples.
- [HDLBits: Vectors and More Verilog Features](https://hdlbits.01xz.net/wiki/Vector0): the vector, concatenation, and replication problems are excellent practice.
- [ChipVerify: Verilog operators](https://www.chipverify.com/verilog/verilog-operators): a reference with more examples of each operator.
- [Sutherland and Mills, "Synthesizing SystemVerilog"](https://sutherland-hdl.com/papers/2013-SNUG-SV_Synthesizable-SystemVerilog_paper.pdf): why `logic` and the other SystemVerilog types help in synthesizable code.
