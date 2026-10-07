// Lesson 10: 10 ns clock on one side, 14 ns on the other. Every pulse must arrive once.
`timescale 1ns/1ps
`default_nettype none

module cdc_tb;
    logic clk_a = 0, clk_b = 0, rst_a_n = 0, rst_b_n = 0, pulse_a = 0;
    wire  pulse_b;
    int sent = 0, got = 0;

    pulse_sync dut (.*);

    always #5 clk_a = ~clk_a;
    always #7 clk_b = ~clk_b;

    always @(posedge clk_b) if (rst_b_n && pulse_b) got++;

    initial begin
        #50 rst_a_n = 1; rst_b_n = 1;
        repeat (50) begin
            @(negedge clk_a) pulse_a = 1;
            @(negedge clk_a) pulse_a = 0;
            sent++;
            repeat ($urandom_range(5, 9)) @(posedge clk_a);   // keep pulses well apart
        end
        repeat (20) @(posedge clk_b);
        if (got == sent) $display("PASS: %0d pulses sent, %0d received", sent, got);
        else             $display("FAIL: %0d pulses sent, %0d received", sent, got);
        $finish;
    end
endmodule

`default_nettype wire
