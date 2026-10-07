// Lesson 11 exercise: this module simulates, but it has problems that show up
// when you run `verilator --lint-only -Wall lint_me.sv`. Fix every warning
// without changing what the module is supposed to do (see the comments).
`timescale 1ns/1ps
`default_nettype none

module lint_me (
    input  wire        clk,
    input  wire        rst_n,
    input  wire  [7:0] din,
    input  wire  [1:0] sel,
    output logic [7:0] acc,            // running sum of din, wraps at 8 bits
    output logic [7:0] pick            // chooses a byte based on sel
);
    logic [3:0] inc;                   // meant to hold din + 1 (all 8 bits)
    logic [7:0] dbg;                   // leftover debug signal that nothing reads

    always_ff @(posedge clk) begin
        if (!rst_n) acc = 0;           // problem: blocking assignment in a flop
        else        acc = acc + din;
    end

    assign inc = din + 1;              // problem: 9-bit result squeezed into 4 bits
    assign dbg = acc ^ din;            // problem: dbg is never used

    always_comb begin
        case (sel)                     // problem: sel == 3 is not covered
            2'd0: pick = din;
            2'd1: pick = acc;
            2'd2: pick = inc;          // problem: width mismatch here as well
        endcase
    end
endmodule

`default_nettype wire
