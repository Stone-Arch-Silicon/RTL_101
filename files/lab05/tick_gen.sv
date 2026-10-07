// Lesson 5 exercise: pulse generator.
// Keep a counter cnt that is 0 after reset, adds 1 at every rising clock edge,
// and goes back to 0 after it reaches N-1.
// Drive tick = 1 whenever cnt equals N-1, and 0 otherwise.
// Result: tick is 1 for exactly one clock cycle out of every N.
`timescale 1ns/1ps
`default_nettype none

module tick_gen #(parameter int N = 5) (
    input  wire  clk,
    input  wire  rst_n,
    output logic tick
);
    // TODO: declare cnt, write the always_ff block, and replace this assign.
    // Hint: $clog2(N) is the number of bits needed to hold the values 0 to N-1.
    assign tick = 1'b0;
endmodule

`default_nettype wire
