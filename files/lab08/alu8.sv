// Lesson 8 exercise: 8-bit ALU with flags.
// Two things are missing: the overflow flag v, and the SLT operation.
`timescale 1ns/1ps
`default_nettype none

module alu8 (
    input  wire  [7:0] a,
    input  wire  [7:0] b,
    input  wire  [2:0] op,
    output logic [7:0] y,
    output logic       z,    // zero: y == 0
    output logic       n,    // negative: y[7]
    output logic       c,    // carry out of the adder (ADD and SUB only, else 0)
    output logic       v     // signed overflow (ADD and SUB only, else 0)
);
    `include "alu_ops.svh"

    // one adder does both ADD and SUB: a - b = a + ~b + 1
    logic       sub;
    logic [7:0] b_in;
    logic [8:0] sum;          // 9 bits so we keep the carry out
    logic       ovf;

    assign sub  = (op == OP_SUB) || (op == OP_SLT);
    assign b_in = sub ? ~b : b;
    assign sum  = {1'b0, a} + {1'b0, b_in} + {8'd0, sub};

    // TODO 1: ovf, the signed overflow of the add/subtract.
    // Overflow means the true answer does not fit in 8 signed bits.
    // It happens when a and b_in have the same sign but sum[7] has the other sign.
    assign ovf = 1'b0;

    always_comb begin
        y = 8'd0;
        case (op)
            OP_ADD, OP_SUB: y = sum[7:0];
            OP_AND:         y = a & b;
            OP_OR:          y = a | b;
            OP_XOR:         y = a ^ b;
            OP_SLL:         y = a << b[2:0];
            OP_SRL:         y = a >> b[2:0];
            // TODO 2: a < b (signed) is true when the subtraction result is
            // negative, unless it overflowed, in which case the sign is backwards.
            OP_SLT:         y = 8'd0;
            default:        y = 8'd0;
        endcase
    end

    assign z = (y == 8'd0);
    assign n = y[7];
    assign c = (op == OP_ADD || op == OP_SUB) ? sum[8] : 1'b0;
    assign v = (op == OP_ADD || op == OP_SUB) ? ovf : 1'b0;
endmodule

`default_nettype wire
