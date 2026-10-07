// Lesson 7: a counter with a configurable width and wrap value.
// count goes 0, 1, ..., MAX, 0, ... and wrap is 1 during the cycle when count == MAX.
`timescale 1ns/1ps
`default_nettype none

module counter_n #(
    parameter int WIDTH = 8,
    parameter int MAX   = (1 << WIDTH) - 1
) (
    input  wire             clk,
    input  wire             rst_n,
    input  wire             en,
    output logic [WIDTH-1:0] count,
    output logic             wrap
);
    localparam logic [WIDTH-1:0] LAST = WIDTH'(MAX);

    always_ff @(posedge clk) begin
        if (!rst_n)        count <= '0;
        else if (en) begin
            if (count == LAST) count <= '0;
            else               count <= count + 1'b1;
        end
    end

    assign wrap = en && (count == LAST);
endmodule

`default_nettype wire
