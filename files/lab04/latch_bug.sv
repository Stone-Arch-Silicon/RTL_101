// Lesson 4 exercise: this block accidentally builds a latch.
// Run `make lint` and `make synth` to see the tools complain, then fix it.
`timescale 1ns/1ps
`default_nettype none

module latch_bug (
    input  wire  [1:0] mode,
    input  wire  [7:0] a,
    input  wire  [7:0] b,
    output logic [7:0] y
);
    always @* begin
        case (mode)
            2'd0: y = a;
            2'd1: y = b;
            2'd2: y = a & b;
            // mode 3 is missing, so y must "remember" its old value
        endcase
    end
endmodule

`default_nettype wire
