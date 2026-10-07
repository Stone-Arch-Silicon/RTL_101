// Lesson 3: a 4-to-1 mux built from three mux2 instances (structural style).
`timescale 1ns/1ps
`default_nettype none

module mux4 #(parameter int W = 1) (
    input  wire [W-1:0] d0, d1, d2, d3,
    input  wire [1:0]   sel,
    output wire [W-1:0] y
);
    wire [W-1:0] lo, hi;   // internal wires connect the instances

    mux2 #(.W(W)) m_lo  (.a(d0), .b(d1), .sel(sel[0]), .y(lo));
    mux2 #(.W(W)) m_hi  (.a(d2), .b(d3), .sel(sel[0]), .y(hi));
    mux2 #(.W(W)) m_out (.a(lo), .b(hi), .sel(sel[1]), .y(y));
endmodule

`default_nettype wire
