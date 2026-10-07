// Lesson 9 exercise: synchronous FIFO (first in, first out).
// rd_data always shows the oldest entry ("first-word fall-through"),
// and rd_en removes it. Pushes are ignored when full; pops are ignored when empty.
//
// The read and write pointers have one extra bit. The low bits pick a slot
// in mem; the extra top bit flips every time a pointer wraps around.
`timescale 1ns/1ps
`default_nettype none

module sync_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 8          // must be a power of two
) (
    input  wire              clk,
    input  wire              rst_n,
    input  wire              wr_en,
    input  wire  [WIDTH-1:0] wr_data,
    input  wire              rd_en,
    output logic [WIDTH-1:0] rd_data,
    output logic             full,
    output logic             empty,
    output logic [$clog2(DEPTH):0] count
);
    localparam int AW = $clog2(DEPTH);

    logic [WIDTH-1:0] mem [DEPTH];
    logic [AW:0]      wr_ptr, rd_ptr;
    logic             do_wr, do_rd;

    assign do_wr = wr_en && !full;
    assign do_rd = rd_en && !empty;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
        end else begin
            if (do_wr) begin
                mem[wr_ptr[AW-1:0]] <= wr_data;
                wr_ptr <= wr_ptr + 1'b1;
            end
            if (do_rd) rd_ptr <= rd_ptr + 1'b1;
        end
    end

    assign rd_data = mem[rd_ptr[AW-1:0]];
    assign count   = wr_ptr - rd_ptr;

    // TODO: empty when both pointers are identical.
    // TODO: full when the low bits match but the extra top bits differ.
    assign empty = 1'b0;
    assign full  = 1'b0;
endmodule

`default_nettype wire
