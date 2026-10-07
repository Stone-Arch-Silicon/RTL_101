// Lesson 11: a 32-bit adder written the short way. Compare it with the
// hand-built ripple-carry adder_n from Lesson 7 using `make adders`.
`timescale 1ns/1ps
`default_nettype none

module add32 (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [32:0] s
);
    assign s = a + b;
endmodule

`default_nettype wire
