// Lesson 7 exercise: Gray code converters for any width W.
// In Gray code, neighbouring numbers differ in exactly one bit.
//   binary to Gray: g = b XOR (b shifted right by 1)
//   Gray to binary: b[W-1] = g[W-1], and each lower bit b[i] = b[i+1] XOR g[i]
`timescale 1ns/1ps
`default_nettype none

module bin2gray #(parameter int W = 8) (
    input  wire  [W-1:0] bin,
    output logic [W-1:0] gray
);
    // TODO: one assign statement
    assign gray = '0;
endmodule

`default_nettype wire
