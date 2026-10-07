// Lesson 10 exercise solution.
`timescale 1ns/1ps
`default_nettype none

module mac_pipe (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         in_valid,
    input  wire  [7:0]  a,
    input  wire  [7:0]  b,
    input  wire  [15:0] c,
    output logic        out_valid,
    output logic [16:0] y
);
    logic [15:0] p1, c1;     // stage 1 data
    logic        v1;         // stage 1 valid

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            v1        <= 1'b0;
            out_valid <= 1'b0;
        end else begin
            v1        <= in_valid;
            out_valid <= v1;
        end
        p1 <= a * b;          // data registers: no reset needed
        c1 <= c;
        y  <= p1 + c1;
    end
endmodule

`default_nettype wire
