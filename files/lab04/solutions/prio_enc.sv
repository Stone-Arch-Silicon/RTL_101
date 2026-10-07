// Lesson 4 exercise solution: an if/else chain checks the highest bit first.
`timescale 1ns/1ps
`default_nettype none

module prio_enc (
    input  wire  [7:0] req,
    output logic [2:0] idx,
    output logic       valid
);
    always_comb begin
        idx   = 3'd0;          // defaults: every path assigns every output
        valid = 1'b1;
        if      (req[7]) idx = 3'd7;
        else if (req[6]) idx = 3'd6;
        else if (req[5]) idx = 3'd5;
        else if (req[4]) idx = 3'd4;
        else if (req[3]) idx = 3'd3;
        else if (req[2]) idx = 3'd2;
        else if (req[1]) idx = 3'd1;
        else if (req[0]) idx = 3'd0;
        else             valid = 1'b0;
    end
endmodule

`default_nettype wire
