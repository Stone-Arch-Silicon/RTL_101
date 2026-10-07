// Lesson 7: an N-bit ripple-carry adder. A generate loop stamps out N full adders.
`timescale 1ns/1ps
`default_nettype none

module adder_n #(parameter int N = 8) (
    input  wire [N-1:0] a,
    input  wire [N-1:0] b,
    input  wire         cin,
    output wire [N-1:0] sum,
    output wire         cout
);
    wire [N:0] c;
    assign c[0] = cin;
    assign cout = c[N];

    for (genvar i = 0; i < N; i++) begin : g_bit
        full_adder fa (.a(a[i]), .b(b[i]), .cin(c[i]), .sum(sum[i]), .cout(c[i+1]));
    end
endmodule

`default_nettype wire
