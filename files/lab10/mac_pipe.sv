// Lesson 10 exercise: the same y = a * b + c, split into two pipeline stages.
//   stage 1 (first edge):  register p = a * b, register c, register the valid bit
//   stage 2 (second edge): register y = p + c, register the valid bit again
// out_valid is in_valid delayed by exactly two clock cycles.
// A new input may arrive on every cycle; there is no stalling.
`timescale 1ns/1ps
`default_nettype none

module mac_pipe (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         in_valid,
    input  wire  [7:0]  a,
    input  wire  [7:0]  b,
    input  wire  [15:0] c,
    output logic        out_valid,
    output logic [16:0] y
);
    // TODO: stage 1 registers (product, c, valid) and stage 2 registers (y, valid).
    // Only the valid bits need a reset; data registers can skip it.
    assign out_valid = 1'b0;
    assign y = '0;
endmodule

`default_nettype wire
