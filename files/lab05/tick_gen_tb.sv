// Lesson 5 exercise: checks tick_gen with N = 5 and N = 1000.
// After rising edge k (counting from 1 after reset), cnt = k mod N,
// so tick must be 1 exactly when k mod N equals N-1.
`timescale 1ns/1ps
`default_nettype none

module tick_gen_tb;
    logic clk = 0, rst_n = 0;
    wire  tick5, tick1000;
    int   errors = 0, seen5 = 0, seen1000 = 0;

    tick_gen #(.N(5))    u5    (.clk, .rst_n, .tick(tick5));
    tick_gen #(.N(1000)) u1000 (.clk, .rst_n, .tick(tick1000));

    always #5 clk = ~clk;

    initial begin
        repeat (3) @(posedge clk);
        @(negedge clk) rst_n = 1;            // release reset between edges
        for (int k = 1; k <= 3000; k++) begin
            @(posedge clk); #1;              // look just after edge k
            if (tick5 !== (k % 5 == 4)) begin
                if (errors < 5) $display("N=5: tick=%b after edge %0d", tick5, k);
                errors++;
            end
            if (tick1000 !== (k % 1000 == 999)) begin
                if (errors < 5) $display("N=1000: tick=%b after edge %0d", tick1000, k);
                errors++;
            end
            seen5    += tick5;
            seen1000 += tick1000;
        end
        if (errors == 0 && seen5 == 600 && seen1000 == 3)
            $display("PASS: ticks on time (600 for N=5, 3 for N=1000)");
        else
            $display("FAIL: %0d errors; %0d ticks for N=5 (want 600), %0d for N=1000 (want 3)",
                     errors, seen5, seen1000);
        $finish;
    end
endmodule

`default_nettype wire
