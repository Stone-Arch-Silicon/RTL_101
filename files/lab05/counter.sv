// Lesson 5: an 8-bit counter with synchronous active-low reset and an enable.
`timescale 1ns/1ps
`default_nettype none

module counter (
    input  wire        clk,
    input  wire        rst_n,   // 0 = reset (checked only at a rising clock edge)
    input  wire        en,      // count only when en is 1
    output logic [7:0] count
);
    always_ff @(posedge clk) begin
        if (!rst_n)  count <= 8'd0;
        else if (en) count <= count + 8'd1;
        // no else: when en is 0 the register simply keeps its value
    end
endmodule

`default_nettype wire
