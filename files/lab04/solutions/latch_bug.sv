// Lesson 4 exercise solution: a default value means every path assigns y.
`timescale 1ns/1ps
`default_nettype none

module latch_bug (
    input  wire  [1:0] mode,
    input  wire  [7:0] a,
    input  wire  [7:0] b,
    output logic [7:0] y
);
    always_comb begin
        y = 8'd0;
        case (mode)
            2'd0: y = a;
            2'd1: y = b;
            2'd2: y = a & b;
            default: y = a | b;
        endcase
    end
endmodule

`default_nettype wire
