// Lesson 7: serial-in, parallel-out shift register. New bits enter at bit 0.
`timescale 1ns/1ps
`default_nettype none

module shift_reg #(parameter int N = 8) (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          din,
    output logic [N-1:0] q
);
    always_ff @(posedge clk) begin
        if (!rst_n) q <= '0;
        else begin
            for (int i = N - 1; i > 0; i--) q[i] <= q[i-1];   // a loop unrolls into N wires
            q[0] <= din;
        end
    end
endmodule

`default_nettype wire
