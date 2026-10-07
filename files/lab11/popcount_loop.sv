// Lesson 11: count the 1 bits in a 16-bit word, written as a loop.
// The loop unrolls into a chain: each addition waits for the one before it.
`timescale 1ns/1ps
`default_nettype none

module popcount_loop (
    input  wire  [15:0] x,
    output logic [4:0]  count
);
    always_comb begin
        count = '0;
        for (int i = 0; i < 16; i++) count = count + 5'(x[i]);
    end
endmodule

`default_nettype wire
