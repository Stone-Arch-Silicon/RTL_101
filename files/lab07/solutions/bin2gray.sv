// Lesson 7 exercise solution.
`timescale 1ns/1ps
`default_nettype none

module bin2gray #(parameter int W = 8) (
    input  wire  [W-1:0] bin,
    output logic [W-1:0] gray
);
    assign gray = bin ^ (bin >> 1);
endmodule

`default_nettype wire
