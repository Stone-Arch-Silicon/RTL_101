// Lesson 6: Moore FSM that detects the pattern 1011 on a serial input.
// Overlapping matches count: the stream 1011011 contains two matches.
// found is 1 for one clock cycle, right after the edge that sampled the final 1.
`timescale 1ns/1ps
`default_nettype none

module seq_1011 (
    input  wire  clk,
    input  wire  rst_n,
    input  wire  din,
    output logic found
);
    // each state name says how much of the pattern we have seen so far
    typedef enum logic [2:0] {S0, S1, S10, S101, S1011} state_t;
    state_t state, next;

    // 1) state register: the only flip-flops in the design
    always_ff @(posedge clk) begin
        if (!rst_n) state <= S0;
        else        state <= next;
    end

    // 2) next-state logic: pure combinational
    always_comb begin
        next = state;                         // default: stay
        case (state)
            S0:    if (din) next = S1;    else next = S0;
            S1:    if (din) next = S1;    else next = S10;
            S10:   if (din) next = S101;  else next = S0;
            S101:  if (din) next = S1011; else next = S10;
            S1011: if (din) next = S1;    else next = S10;
            default: next = S0;
        endcase
    end

    // 3) output logic: in a Moore machine it depends only on the state
    assign found = (state == S1011);
endmodule

`default_nettype wire
