// Lesson 11 exercise solution: clean under verilator --lint-only -Wall.
// The unused dbg signal is simply deleted.
`timescale 1ns/1ps
`default_nettype none

module lint_me (
    input  wire        clk,
    input  wire        rst_n,
    input  wire  [7:0] din,
    input  wire  [1:0] sel,
    output logic [7:0] acc,
    output logic [7:0] pick
);
    logic [7:0] inc;

    always_ff @(posedge clk) begin
        if (!rst_n) acc <= 8'd0;
        else        acc <= acc + din;
    end

    assign inc = din + 8'd1;

    always_comb begin
        case (sel)
            2'd0:    pick = din;
            2'd1:    pick = acc;
            2'd2:    pick = inc;
            default: pick = 8'd0;
        endcase
    end
endmodule

`default_nettype wire
