// Lesson 10: multiply-accumulate step, all in one combinational cloud.
// y = a * b + c. The multiplier and adder in series make a long path.
`timescale 1ns/1ps
`default_nettype none

module mac_comb (
    input  wire  [7:0]  a,
    input  wire  [7:0]  b,
    input  wire  [15:0] c,
    output logic [16:0] y
);
    assign y = a * b + c;
endmodule

`default_nettype wire
