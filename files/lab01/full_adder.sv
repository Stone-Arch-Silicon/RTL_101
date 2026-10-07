// Lesson 1 exercise: finish the full adder.
// A full adder adds three bits: a, b, and a carry coming in (cin).
`timescale 1ns/1ps
`default_nettype none

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    // TODO: replace the two lines below with the real equations.
    assign sum  = 1'b0;
    assign cout = 1'b0;
endmodule

`default_nettype wire
