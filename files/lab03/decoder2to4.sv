// Lesson 3: 2-to-4 decoder. Exactly one output bit is 1 when en is 1.
`timescale 1ns/1ps
`default_nettype none

module decoder2to4 (
    input  wire [1:0] in,
    input  wire       en,
    output wire [3:0] out
);
    assign out = en ? (4'b0001 << in) : 4'b0000;
endmodule

`default_nettype wire
