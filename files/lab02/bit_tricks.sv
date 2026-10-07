// Lesson 2 exercise: fill in each assign using only operators (no always blocks yet).
`timescale 1ns/1ps
`default_nettype none

module bit_tricks (
    input  wire  [7:0]  x,
    output logic        is_neg,    // 1 when x is negative as a signed 8-bit number
    output logic [7:0]  negated,   // -x in two's complement (8 bits, wraps for -128)
    output logic        parity,    // 1 when x has an odd number of 1 bits
    output logic        all_ones,  // 1 when every bit of x is 1
    output logic [7:0]  swapped,   // upper and lower 4 bits of x exchanged
    output logic [15:0] sext       // x sign-extended to 16 bits
);
    // TODO: replace each 0 with the right expression.
    assign is_neg   = 1'b0;
    assign negated  = 8'd0;
    assign parity   = 1'b0;
    assign all_ones = 1'b0;
    assign swapped  = 8'd0;
    assign sext     = 16'd0;
endmodule

`default_nettype wire
