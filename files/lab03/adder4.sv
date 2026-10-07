// Lesson 3 exercise: a 4-bit ripple-carry adder made of four full_adder instances.
// The carry out of each bit feeds the carry in of the next bit.
`timescale 1ns/1ps
`default_nettype none

module adder4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    wire [4:0] c;          // c[0] is the carry in, c[4] is the carry out
    assign c[0] = cin;
    assign cout = c[4];

    // TODO: instantiate full_adder four times, one per bit.
    // Bit i adds a[i], b[i], and c[i]; it drives sum[i] and c[i+1].
    assign sum = 4'b0000;            // delete this line once your instances drive sum
    assign c[4:1] = 4'b0000;         // delete this line too
endmodule

`default_nettype wire
