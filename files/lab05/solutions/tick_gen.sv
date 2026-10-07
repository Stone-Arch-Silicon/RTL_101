// Lesson 5 exercise solution.
`timescale 1ns/1ps
`default_nettype none

module tick_gen #(parameter int N = 5) (
    input  wire  clk,
    input  wire  rst_n,
    output logic tick
);
    localparam int W = (N > 1) ? $clog2(N) : 1;
    logic [W-1:0] cnt;

    always_ff @(posedge clk) begin
        if (!rst_n)                cnt <= '0;
        else if (cnt == W'(N - 1)) cnt <= '0;
        else                       cnt <= cnt + 1'b1;
    end

    assign tick = rst_n && (cnt == W'(N - 1));
endmodule

`default_nettype wire
