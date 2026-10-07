// Lesson 10 exercise: random inputs every cycle; results must come out two cycles later.
`timescale 1ns/1ps
`default_nettype none

module mac_pipe_tb;
    logic clk = 0, rst_n = 0, in_valid = 0;
    logic [7:0] a = 0, b = 0;
    logic [15:0] c = 0;
    wire  out_valid;
    wire  [16:0] y;
    logic [17:0] pipe [2];      // {valid, expected y} for the two stages in flight
    int errors = 0, results = 0;

    mac_pipe dut (.*);

    always #5 clk = ~clk;

    initial begin
        pipe[0] = 0; pipe[1] = 0;
        repeat (2) @(posedge clk);
        @(negedge clk) rst_n = 1;
        repeat (2000) begin
            @(negedge clk);
            in_valid = $urandom_range(0, 3) != 0;
            a = $urandom; b = $urandom; c = $urandom;
            @(posedge clk);
            pipe[1] = pipe[0];
            pipe[0] = {in_valid, 17'(a * b + c)};
            #1;
            if (out_valid !== pipe[1][17] || (out_valid && y !== pipe[1][16:0])) begin
                if (errors < 5) $display("t=%0t out_valid=%b y=%0d, expected valid=%b y=%0d",
                                         $time, out_valid, y, pipe[1][17], pipe[1][16:0]);
                errors++;
            end
            results += out_valid;
        end
        if (errors == 0) $display("PASS: %0d results, all on time and correct", results);
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule

`default_nettype wire
