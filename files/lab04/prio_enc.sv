// Lesson 4 exercise: 8-input priority encoder.
// idx is the position of the highest-numbered 1 in req.
// valid is 1 when any request bit is 1. When valid is 0, idx must be 0.
`timescale 1ns/1ps
`default_nettype none

module prio_enc (
    input  wire  [7:0] req,
    output logic [2:0] idx,
    output logic       valid
);
    always_comb begin
        // TODO: give idx and valid default values first, then use if/else or casez.
        idx   = 3'd0;
        valid = 1'b0;
    end
endmodule

`default_nettype wire
