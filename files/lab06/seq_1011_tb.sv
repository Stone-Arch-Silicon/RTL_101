// Lesson 6: random serial stream; a 4-bit shift register is the reference model.
`timescale 1ns/1ps
`default_nettype none

module seq_1011_tb;
    logic clk = 0, rst_n = 0, din = 0;
    wire  found;
    logic [3:0] hist = 0;         // last four bits the design has sampled
    int errors = 0, hits = 0;

    seq_1011 dut (.clk, .rst_n, .din, .found);

    always #5 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, seq_1011_tb);
        repeat (2) @(posedge clk);
        @(negedge clk) rst_n = 1;
        for (int k = 0; k < 2000; k++) begin
            @(negedge clk) din = $urandom_range(0, 1);
            @(posedge clk) hist = {hist[2:0], din};
            #1;
            if (found !== (hist == 4'b1011)) begin
                if (errors < 5) $display("after bit %0d (history %b): found=%b", k, hist, found);
                errors++;
            end
            hits += found;
        end
        if (errors == 0) $display("PASS: %0d hits found in 2000 random bits, no mistakes", hits);
        else             $display("FAIL: %0d mistakes", errors);
        $finish;
    end
endmodule

`default_nettype wire
