// Lesson 8: exhaustive test. Every op with every pair of 8-bit inputs:
// 8 x 256 x 256 = 524,288 cases, compared against a simple integer model.
`timescale 1ns/1ps
`default_nettype none

module alu8_tb;
    `include "alu_ops.svh"

    logic [7:0] a, b;
    logic [2:0] op;
    wire  [7:0] y;
    wire        z, n, c, v;
    int errors = 0;

    function automatic string name(input logic [2:0] o);
        case (o)
            OP_ADD: name = "ADD";  OP_SUB: name = "SUB";  OP_AND: name = "AND";  OP_OR:  name = "OR";
            OP_XOR: name = "XOR";  OP_SLL: name = "SLL";  OP_SRL: name = "SRL";  default: name = "SLT";
        endcase
    endfunction

    alu8 dut (.a, .b, .op, .y, .z, .n, .c, .v);

    initial begin
        for (int k = 0; k < 8; k++) begin
            for (int i = 0; i < 256; i++) begin
                for (int j = 0; j < 256; j++) begin
                    int sa, sb, full;
                    logic [7:0] ey;
                    logic ec, ev;
                    op = k[2:0]; a = i[7:0]; b = j[7:0];
                    #1;
                    sa = $signed(a); sb = $signed(b);   // -128 .. 127
                    ec = 0; ev = 0;
                    case (op)
                        OP_ADD: begin full = sa + sb; ey = 8'(i + j);       ec = (i + j) > 255;  ev = (full > 127) || (full < -128); end
                        OP_SUB: begin full = sa - sb; ey = 8'(i - j + 256); ec = (i >= j);       ev = (full > 127) || (full < -128); end
                        OP_AND: ey = a & b;
                        OP_OR:  ey = a | b;
                        OP_XOR: ey = a ^ b;
                        OP_SLL: ey = a << b[2:0];
                        OP_SRL: ey = a >> b[2:0];
                        default: ey = (sa < sb) ? 8'd1 : 8'd0;
                    endcase
                    if (y !== ey || {z, n, c, v} !== {ey == 8'd0, ey[7], ec, ev}) begin
                        if (errors < 8)
                            $display("%s a=%0d b=%0d: y=%0d znvc=%b%b%b%b, expected y=%0d znvc=%b%b%b%b",
                                     name(op), a, b, y, z, n, v, c, ey, ey == 0, ey[7], ev, ec);
                        errors++;
                    end
                end
            end
        end
        if (errors == 0) $display("PASS: all 524288 cases correct");
        else             $display("FAIL: %0d of 524288 cases wrong", errors);
        $finish;
    end
endmodule

`default_nettype wire
