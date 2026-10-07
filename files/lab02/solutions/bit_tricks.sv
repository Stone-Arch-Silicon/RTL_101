// Lesson 2 exercise solution.
`timescale 1ns/1ps
`default_nettype none

module bit_tricks (
    input  wire  [7:0]  x,
    output logic        is_neg,
    output logic [7:0]  negated,
    output logic        parity,
    output logic        all_ones,
    output logic [7:0]  swapped,
    output logic [15:0] sext
);
    assign is_neg   = x[7];                 // the sign bit
    assign negated  = ~x + 8'd1;            // invert and add one
    assign parity   = ^x;                   // XOR of all bits
    assign all_ones = &x;                   // AND of all bits
    assign swapped  = {x[3:0], x[7:4]};
    assign sext     = {{8{x[7]}}, x};       // copy the sign bit 8 times
endmodule

`default_nettype wire
