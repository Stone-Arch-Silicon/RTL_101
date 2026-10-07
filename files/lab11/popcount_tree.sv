// Lesson 11: the same function written as an adder tree.
// Pairs of bits, then pairs of pairs, and so on: about log2(16) = 4 levels.
`timescale 1ns/1ps
`default_nettype none

module popcount_tree (
    input  wire  [15:0] x,
    output logic [4:0]  count
);
    logic [1:0] s1 [8];   // 8 sums of 2 bits, each 0..2
    logic [2:0] s2 [4];   // 4 sums of 4 bits, each 0..4
    logic [3:0] s3 [2];   // 2 sums of 8 bits, each 0..8

    always_comb begin
        for (int i = 0; i < 8; i++) s1[i] = {1'b0, x[2*i]} + {1'b0, x[2*i+1]};
        for (int i = 0; i < 4; i++) s2[i] = {1'b0, s1[2*i]} + {1'b0, s1[2*i+1]};
        for (int i = 0; i < 2; i++) s3[i] = {1'b0, s2[2*i]} + {1'b0, s2[2*i+1]};
        count = {1'b0, s3[0]} + {1'b0, s3[1]};
    end
endmodule

`default_nettype wire
