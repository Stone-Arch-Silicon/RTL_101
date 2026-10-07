# Lesson 9: Memories and FIFOs

Registers hold a few values. Memories hold many, indexed by an address. This lesson builds a register file and a FIFO, the buffer that sits between almost every pair of blocks that run at different rates.

> [!NOTE]
> Before you start: finish Lesson 8. Plan on about two and a half hours. Lab files are in [`files/lab09`](../files/lab09/).

## What you will learn

- How to declare and use an array of registers
- Read ports, write ports, and the difference between combinational and registered reads
- How chips implement big memories (SRAM macros) versus small ones (flip-flops)
- How a circular-buffer FIFO tracks full and empty with one extra pointer bit
- How to test a FIFO against a queue model with random traffic

## Key ideas

### Arrays of registers

```systemverilog
logic [7:0] regs [8];          // eight entries, each 8 bits wide

always_ff @(posedge clk) begin
    if (we) regs[waddr] <= wdata;     // write port: one entry per edge
end

assign rdata_a = regs[raddr_a];       // read port A
assign rdata_b = regs[raddr_b];       // read port B
```

The `[7:0]` before the name is the packed width of each entry; the `[8]` after it is the unpacked number of entries (the same as `[0:7]`). This is a register file: every entry is a register, writes happen on the clock, and reads here are combinational, so a new address gives new data in the same cycle. A processor's register file looks exactly like this, usually with two read ports and one write port.

### Combinational versus registered reads

- Combinational (asynchronous) read: `assign rdata = mem[raddr];`. Data appears in the same cycle. Only possible when the memory is built from flip-flops.
- Registered (synchronous) read: `always_ff @(posedge clk) rdata <= mem[raddr];`. Data appears one cycle after the address. Real SRAM blocks work this way, so designs that will use SRAM should be written with registered reads from the start.

### How chips store large memories

Flip-flops are big: one bit in SKY130 takes about as much area as five simple gates. A memory of a few dozen words is fine as flip-flops, but kilobytes need an SRAM macro, a pre-designed block with a dense array of 6-transistor bit cells, made by a memory compiler such as [OpenRAM](https://openram.org/). In a layout, macros are the big rectangles that physical design places first:

![OpenROAD GUI showing large memory macros placed in a design](https://openroad-flow-scripts.readthedocs.io/en/latest/_images/macro_place_full_view.webp "Macro placement in OpenROAD: the large blocks are hard macros such as memories, placed before the small standard cells.")

Credit: [OpenROAD-flow-scripts documentation, Flow Tutorial](https://openroad-flow-scripts.readthedocs.io/en/latest/tutorials/FlowTutorial.html), BSD-3-Clause.

### The FIFO

A FIFO (first in, first out) is a queue in hardware. A producer writes items when the FIFO is not full; a consumer reads them in the same order when it is not empty. Inside is a small memory used as a circular buffer, with a write pointer and a read pointer that both wrap around.

The hard part is telling full from empty, because in both cases the two pointers point at the same slot. The standard trick is one extra pointer bit that flips every time a pointer wraps:

| Situation | Low bits | Extra top bit |
|---|---|---|
| Empty | equal | equal (both pointers have wrapped the same number of times) |
| Full | equal | different (the write pointer is exactly one lap ahead) |

With `DEPTH = 8` the pointers are 4 bits: 3 bits of address and 1 lap bit. The number of stored items is simply `wr_ptr - rd_ptr`, wrapping naturally in 4 bits.

```mermaid
flowchart LR
    P[producer] -- "wr_en, wr_data" --> F[(FIFO memory + pointers)]
    F -- "full" --> P
    F -- "rd_data, empty" --> C[consumer]
    C -- "rd_en" --> F
```

This FIFO is first-word fall-through: `rd_data` always shows the oldest item, and `rd_en` removes it. Some FIFOs instead present the data one cycle after `rd_en`; both styles are common, so always check which one a FIFO uses.

## Worked example: register file and FIFO testbenches

[`files/lab09/regfile_tb.sv`](../files/lab09/regfile_tb.sv) keeps a model array and compares both read ports against it for 1,000 random cycles. Run it with `make sim`.

The FIFO testbench, [`files/lab09/sync_fifo_tb.sv`](../files/lab09/sync_fifo_tb.sv), uses a SystemVerilog queue as its model. A queue is a variable-size array with `push_back`, `pop_front`, and `size`:

```systemverilog
logic [7:0] model [$];            // the $ makes it a queue

// before each edge: decide what the FIFO should do, using the same rules as the design
will_pop  = rd_en && (model.size() > 0);
will_push = wr_en && (model.size() < 8);   // a full FIFO ignores pushes
@(posedge clk);
if (will_pop)  void'(model.pop_front());
if (will_push) model.push_back(wr_data);
```

Between edges it checks that `empty`, `full`, `count`, and `rd_data` all agree with the model. The traffic alternates between phases that mostly write and phases that mostly read, so the FIFO really does fill up and drain. A FIFO test that never reaches full has not tested the full logic.

```bash
cd files/lab09
make sim
make fifo
```

## Exercises

### Warm-up

1. A FIFO has `DEPTH = 4`, so 3-bit pointers. Starting from reset, the producer writes 6 items and the consumer reads 2, in some interleaving that never overflows. What are `wr_ptr`, `rd_ptr`, and `count` at the end? Is the FIFO full?
2. Why can't the FIFO use 2-bit pointers for `DEPTH = 4` and still tell full from empty?
3. In `regfile.sv`, what does `rdata_a` show if you write and read the same address in the same cycle: the old value or the new one?

### Core

4. Complete the two flag lines in [`files/lab09/sync_fifo.sv`](../files/lab09/sync_fifo.sv). Run `make fifo` until it passes with full reached many times.
5. Add a parameter `AF_LEVEL` and an output `almost_full` that is 1 when `count >= AF_LEVEL`. Producers that need a few cycles to stop use this to avoid overflow. Extend the testbench to check it.
6. Change the register file so that register 0 always reads as zero and ignores writes (as in RISC-V). Update the testbench model to match.

### Stretch

7. Write a stack (last in, first out) with `push`, `pop`, `din`, `top`, `empty`, and `full`. If both `push` and `pop` arrive in the same cycle, push wins. Test it against a queue model using `push_back` and `pop_back`.
8. Convert the FIFO to a registered read: `rd_data` updates on the clock edge after `rd_en`. Write down the new timing as a WaveDrom diagram first, then change the design and the testbench.

## Solutions

<details>
<summary>Exercise 1: pointer arithmetic</summary>

`wr_ptr = 6` (binary 110), `rd_ptr = 2` (010), `count = 6 - 2 = 4`. The low bits are equal (10 and 10) and the lap bits differ (1 and 0), so the FIFO is full: 4 items in a depth-4 FIFO.

</details>

<details>
<summary>Exercise 2: why the extra bit</summary>

With 2-bit pointers, "4 items" and "0 items" both leave the pointers equal, so the count `wr_ptr - rd_ptr` is 0 in both cases. Five situations (0 to 4 items) cannot fit in four pointer differences. The extra bit doubles the range so the difference can reach 4.

</details>

<details>
<summary>Exercise 3: read during write</summary>

The old value. The write happens at the clock edge, and the combinational read shows the stored value until then. After the edge, the read shows the new value. This is called read-before-write behavior.

</details>

<details>
<summary>Exercise 4: full and empty</summary>

```systemverilog
assign empty = (wr_ptr == rd_ptr);
assign full  = (wr_ptr[AW] != rd_ptr[AW]) && (wr_ptr[AW-1:0] == rd_ptr[AW-1:0]);
```

Full file: [`files/lab09/solutions/sync_fifo.sv`](../files/lab09/solutions/sync_fifo.sv).

</details>

<details>
<summary>Exercise 5: almost full</summary>

```systemverilog
parameter int AF_LEVEL = DEPTH - 2,
...
output logic almost_full,
...
assign almost_full = (count >= AF_LEVEL);
```

In the testbench: `check("almost_full wrong", almost_full === (model.size() >= AF_LEVEL));`.

</details>

<details>
<summary>Exercise 6: hardwired zero register</summary>

```systemverilog
always_ff @(posedge clk) begin
    if (we && waddr != 3'd0) regs[waddr] <= wdata;
end
assign rdata_a = (raddr_a == 3'd0) ? 8'd0 : regs[raddr_a];
assign rdata_b = (raddr_b == 3'd0) ? 8'd0 : regs[raddr_b];
```

In the model, never write entry 0 and keep it at zero.

</details>

<details>
<summary>Exercise 7: stack</summary>

```systemverilog
module stack #(parameter int WIDTH = 8, parameter int DEPTH = 8) (
    input  wire              clk, rst_n,
    input  wire              push, pop,
    input  wire  [WIDTH-1:0] din,
    output logic [WIDTH-1:0] top,
    output logic             empty, full
);
    localparam int AW = $clog2(DEPTH);
    localparam logic [AW:0] FULL_COUNT = DEPTH[AW:0];
    logic [WIDTH-1:0] mem [DEPTH];
    logic [AW:0]      sp;                    // number of items, 0 to DEPTH

    assign empty = (sp == 0);
    assign full  = (sp == FULL_COUNT);
    assign top   = mem[AW'(sp - 1'b1)];      // meaningful only when not empty

    always_ff @(posedge clk) begin
        if (!rst_n) sp <= '0;
        else if (push && !full) begin        // push wins if both are requested
            mem[sp[AW-1:0]] <= din;
            sp <= sp + 1'b1;
        end else if (pop && !empty) begin
            sp <= sp - 1'b1;
        end
    end
endmodule
```

</details>

<details>
<summary>Exercise 8: registered read</summary>

Add a register for the output and load it when a read happens:

```systemverilog
always_ff @(posedge clk) begin
    if (do_rd) rd_data <= mem[rd_ptr[AW-1:0]];
end
```

Now `rd_data` is valid in the cycle after `rd_en` was accepted. In the testbench, pop the model at the edge but compare `rd_data` with the popped value one cycle later.

</details>

## Common mistakes

- Using `$clog2(DEPTH)` bits for the count. A depth-8 FIFO holds 0 to 8 items: 9 values need 4 bits.
- Writing to a full FIFO or reading an empty one without checking the flags. The design ignores the request, but the producer believes it happened.
- Never letting the testbench fill the FIFO. Full and almost-full bugs then survive until silicon.
- Expecting a large flip-flop array to be cheap. Ask early whether a memory should be an SRAM macro.

## Checklist

- [ ] You can explain the extra pointer bit with a depth-4 example
- [ ] The register file and FIFO testbenches pass
- [ ] Your FIFO test reaches the full state many times
- [ ] You know when a memory should be flip-flops and when it should be an SRAM macro

## Further reading

- [Cummings, "Simulation and Synthesis Techniques for Asynchronous FIFO Design"](http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf): the standard reference for FIFOs, including the clock-crossing version you will meet in Lesson 10.
- [ZipCPU: Building a basic FIFO](https://zipcpu.com/blog/2017/07/29/fifo.html): a careful walk-through with formal properties.
- [OpenRAM](https://openram.org/): the open-source memory compiler used for SKY130 SRAM macros.
- [HDLBits: Building Larger Circuits](https://hdlbits.01xz.net/wiki/Exams/review2015_count1k): practice combining counters, memories, and FSMs.
