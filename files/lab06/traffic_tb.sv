// Lesson 6 exercise: checks five full red-green-yellow rounds.
// After rising edge k (k = 0 means just after reset is released) the expected
// light repeats every 11 cycles: 4 red, 5 green, 2 yellow.
`timescale 1ns/1ps
`default_nettype none

module traffic_tb;
    logic clk = 0, rst_n = 0;
    wire  [2:0] lights;
    int errors = 0;

    traffic dut (.clk, .rst_n, .lights);

    always #5 clk = ~clk;

    function automatic logic [2:0] expected(input int k);
        int p;
        p = k % 11;
        if (p < 4)      expected = 3'b100;   // red
        else if (p < 9) expected = 3'b001;   // green
        else            expected = 3'b010;   // yellow
    endfunction

    initial begin
        repeat (2) @(posedge clk);
        #1 if (lights !== 3'b100) begin $display("not red during reset"); errors++; end
        @(negedge clk) rst_n = 1;
        if (lights !== expected(0)) begin $display("k=0: lights=%b", lights); errors++; end
        for (int k = 1; k <= 55; k++) begin
            @(posedge clk); #1;
            if (lights !== expected(k)) begin
                if (errors < 6) $display("after edge %0d: lights=%b expected %b", k, lights, expected(k));
                errors++;
            end
        end
        if (errors == 0) $display("PASS: five rounds with correct timing");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule

`default_nettype wire
