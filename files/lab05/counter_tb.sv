// Lesson 5: clocked testbench for counter.
`timescale 1ns/1ps
`default_nettype none

module counter_tb;
    logic       clk = 0;
    logic       rst_n = 0;
    logic       en = 0;
    wire  [7:0] count;
    logic [7:0] model = 0;      // what the counter should hold
    int errors = 0;

    counter dut (.clk, .rst_n, .en, .count);

    always #5 clk = ~clk;       // 10 ns period, so a 100 MHz clock

    // update the model at every rising edge, using the same rules as the design
    always @(posedge clk) begin
        if (!rst_n)  model <= 0;
        else if (en) model <= model + 1;
    end

    // compare on the falling edge, when everything has settled
    always @(negedge clk) begin
        if (rst_n && count !== model) begin
            $display("t=%0t count=%0d expected %0d", $time, count, model);
            errors++;
        end
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, counter_tb);
        repeat (2) @(posedge clk);
        @(negedge clk) rst_n = 1;          // leave reset between clock edges
        @(negedge clk) en = 1;
        repeat (300) begin                 // long enough to see the counter wrap past 255
            @(negedge clk);
            en = ($urandom % 4) != 0;      // enabled about 3 cycles out of 4
        end
        if (errors == 0) $display("PASS: counter matched the model for 300 cycles");
        else             $display("FAIL: %0d mismatches", errors);
        $finish;
    end
endmodule

`default_nettype wire
