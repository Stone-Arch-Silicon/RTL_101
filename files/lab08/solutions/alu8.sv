// Lesson 8 exercise solution.
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

    logic       sub;
    logic [7:0] b_in;
    logic [8:0] sum;
    logic       ovf;

    assign sub  = (op == OP_SUB) || (op == OP_SLT);
    assign b_in = sub ? ~b : b;
    assign sum  = {1'b0, a} + {1'b0, b_in} + {8'd0, sub};

    // same input signs, different result sign
    assign ovf = (a[7] == b_in[7]) && (sum[7] != a[7]);

    always_comb begin
        y = 8'd0;
        case (op)
            OP_ADD, OP_SUB: y = sum[7:0];
            OP_AND:         y = a & b;
            OP_OR:          y = a | b;
            OP_XOR:         y = a ^ b;
            OP_SLL:         y = a << b[2:0];
            OP_SRL:         y = a >> b[2:0];
            OP_SLT:         y = {7'd0, sum[7] ^ ovf};   // negative XOR overflow
            default:        y = 8'd0;
        endcase
    end

    assign z = (y == 8'd0);
    assign n = y[7];
    assign c = (op == OP_ADD || op == OP_SUB) ? sum[8] : 1'b0;
    assign v = (op == OP_ADD || op == OP_SUB) ? ovf : 1'b0;
endmodule

`default_nettype wire
