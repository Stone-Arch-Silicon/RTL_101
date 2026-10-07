// Lesson 9: register file with 8 registers of 8 bits.
// Two read ports (combinational) and one write port (writes on the clock edge).
`timescale 1ns/1ps
`default_nettype none

module regfile (
    input  wire        clk,
    input  wire        we,        // write enable
    input  wire  [2:0] waddr,
    input  wire  [7:0] wdata,
    input  wire  [2:0] raddr_a,
    output logic [7:0] rdata_a,
    input  wire  [2:0] raddr_b,
    output logic [7:0] rdata_b
);
    logic [7:0] regs [8];         // an array of eight 8-bit registers

    always_ff @(posedge clk) begin
        if (we) regs[waddr] <= wdata;
    end

    assign rdata_a = regs[raddr_a];
    assign rdata_b = regs[raddr_b];
endmodule

`default_nettype wire
