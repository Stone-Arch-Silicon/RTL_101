// Lesson 10: valid/ready pipeline stage with a skid slot.
// A transfer happens on a rising edge when valid and ready are both 1.
// out_valid/out_data and in_ready all come straight from flip-flops, which
// keeps long combinational paths from forming between pipeline stages,
// and the stage still moves one item per cycle when nothing stalls.
`timescale 1ns/1ps
`default_nettype none

module skid_buffer #(parameter int W = 8) (
    input  wire          clk,
    input  wire          rst_n,
    // upstream side
    input  wire          in_valid,
    output logic         in_ready,
    input  wire  [W-1:0] in_data,
    // downstream side
    output logic         out_valid,
    input  wire          out_ready,
    output logic [W-1:0] out_data
);
    logic         skid_valid;     // the spare slot holds an item
    logic [W-1:0] skid_data;

    assign in_ready = !skid_valid;   // accept new data while the spare slot is empty

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            out_valid  <= 1'b0;
            skid_valid <= 1'b0;
        end else if (out_ready || !out_valid) begin
            // the output register is free (or being emptied this cycle)
            if (skid_valid) begin
                out_data   <= skid_data;   // drain the spare slot first, keeps order
                out_valid  <= 1'b1;
                skid_valid <= 1'b0;
            end else begin
                out_data   <= in_data;     // pass the new item straight through
                out_valid  <= in_valid;
            end
        end else if (in_valid && in_ready) begin
            // downstream is stalled but upstream already sent: park it
            skid_data  <= in_data;
            skid_valid <= 1'b1;
        end
    end
endmodule

`default_nettype wire
