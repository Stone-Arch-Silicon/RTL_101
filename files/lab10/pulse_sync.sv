// Lesson 10: moves a one-cycle pulse from clock domain A to clock domain B.
// Domain A turns each pulse into a level change (a toggle), the level crosses
// through a 2-flop synchronizer, and domain B turns each change back into a pulse.
// Pulses in domain A must be at least 3 domain-B cycles apart.
`timescale 1ns/1ps
`default_nettype none

module pulse_sync (
    input  wire  clk_a,
    input  wire  rst_a_n,
    input  wire  pulse_a,
    input  wire  clk_b,
    input  wire  rst_b_n,
    output logic pulse_b
);
    logic toggle_a;
    logic toggle_b, toggle_b_d;

    always_ff @(posedge clk_a) begin
        if (!rst_a_n)    toggle_a <= 1'b0;
        else if (pulse_a) toggle_a <= ~toggle_a;
    end

    sync_2ff u_sync (.clk_dst(clk_b), .rst_n(rst_b_n), .d_async(toggle_a), .q_sync(toggle_b));

    always_ff @(posedge clk_b) begin
        if (!rst_b_n) toggle_b_d <= 1'b0;
        else          toggle_b_d <= toggle_b;
    end

    assign pulse_b = toggle_b ^ toggle_b_d;
endmodule

`default_nettype wire
