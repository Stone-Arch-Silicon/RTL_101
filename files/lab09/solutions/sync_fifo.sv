// Lesson 9 exercise solution: only the two flag lines change.
`timescale 1ns/1ps
`default_nettype none

module sync_fifo #(
    parameter int WIDTH = 8,
    parameter int DEPTH = 8
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
    assign empty   = (wr_ptr == rd_ptr);
    assign full    = (wr_ptr[AW] != rd_ptr[AW]) && (wr_ptr[AW-1:0] == rd_ptr[AW-1:0]);
endmodule

`default_nettype wire
