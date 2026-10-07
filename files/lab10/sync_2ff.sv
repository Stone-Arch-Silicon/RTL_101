// Lesson 10: two-flip-flop synchronizer for a single bit that changes slowly.
// The first flop may go metastable; the second gives it a full cycle to settle.
`timescale 1ns/1ps
`default_nettype none

module sync_2ff (
    input  wire  clk_dst,
    input  wire  rst_n,
    input  wire  d_async,     // driven from another clock domain
    output logic q_sync
);
    logic meta;

    always_ff @(posedge clk_dst) begin
        if (!rst_n) begin
            meta   <= 1'b0;
            q_sync <= 1'b0;
        end else begin
            meta   <= d_async;
            q_sync <= meta;
        end
    end
endmodule

`default_nettype wire
