// Full adder from Lesson 1 (reused in the generate example).
`timescale 1ns/1ps
`default_nettype none

module full_adder (
    input  wire a,
    input  wire b,
    input  wire cin,
    output wire sum,
    output wire cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);   // "majority": at least two inputs are 1
endmodule

`default_nettype wire
