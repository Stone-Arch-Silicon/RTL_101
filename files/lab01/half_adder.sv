// Lesson 1: a half adder adds two bits.
// sum is 1 when exactly one input is 1; carry is 1 when both are 1.
`timescale 1ns/1ps
`default_nettype none

module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);
    assign sum   = a ^ b;   // XOR
    assign carry = a & b;   // AND
endmodule

`default_nettype wire
