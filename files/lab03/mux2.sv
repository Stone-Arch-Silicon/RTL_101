// Lesson 3: 2-to-1 multiplexer. y follows a when sel is 0, b when sel is 1.
`timescale 1ns/1ps
`default_nettype none

module mux2 #(parameter int W = 1) (
    input  wire [W-1:0] a,
    input  wire [W-1:0] b,
    input  wire         sel,
    output wire [W-1:0] y
);
    assign y = sel ? b : a;
endmodule

`default_nettype wire
