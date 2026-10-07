// Lesson 10: random stalls on both sides. Items are numbered 0, 1, 2, ...
// The checker makes sure nothing is lost, repeated, or reordered.
`timescale 1ns/1ps
`default_nettype none

module skid_buffer_tb;
    logic clk = 0, rst_n = 0;
    logic in_valid = 0, out_ready = 0;
    logic [7:0] in_data = 0;
    wire  in_ready, out_valid;
    wire  [7:0] out_data;
    logic [7:0] expect_next = 0;
    int errors = 0, received = 0, full_rate_cycles = 0;
    int phase = 0;     // 0: random stalls, 1: no stalls at all

    skid_buffer #(.W(8)) dut (.*);

    always #5 clk = ~clk;

    // source: once valid is raised it stays raised with the same data until accepted
    always @(posedge clk) begin
        if (!rst_n) begin
            in_valid <= 0; in_data <= 0;
        end else begin
            if (in_valid && in_ready) in_data <= in_data + 1;
            if (!in_valid || in_ready) in_valid <= (phase == 1) ? 1'b1 : ($urandom_range(0, 99) < 60);
        end
    end

    // sink: random backpressure, checks every item it accepts
    always @(posedge clk) begin
        if (rst_n) begin
            if (out_valid && out_ready) begin
                if (out_data !== expect_next) begin
                    if (errors < 5) $display("got %0d, expected %0d", out_data, expect_next);
                    errors++;
                end
                expect_next <= out_data + 1;
                received++;
                if (phase == 1) full_rate_cycles++;
            end
            out_ready <= (phase == 1) ? 1'b1 : ($urandom_range(0, 99) < 50);
        end
    end

    initial begin
        repeat (2) @(posedge clk);
        @(negedge clk) rst_n = 1;
        repeat (3000) @(posedge clk);
        phase = 1;                        // now nothing stalls: expect one item per cycle
        repeat (10) @(posedge clk);
        full_rate_cycles = 0;
        repeat (100) @(posedge clk);
        @(negedge clk);
        if (errors == 0 && full_rate_cycles == 100)
            $display("PASS: %0d items in order; 100 items in 100 cycles when nothing stalls", received);
        else
            $display("FAIL: %0d ordering errors, %0d items in the 100-cycle full-rate window",
                     errors, full_rate_cycles);
        $finish;
    end
endmodule

`default_nettype wire
