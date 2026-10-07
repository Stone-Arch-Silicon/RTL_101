// Lesson 7: one testbench, several parameter choices.
`timescale 1ns/1ps
`default_nettype none

module param_tb;
    logic clk = 0, rst_n = 0, en = 0, din = 0;
    int errors = 0;

    // adders of two different widths, built from the same source file
    logic [7:0]  a8, b8;   wire [7:0]  s8;  wire c8;
    logic [15:0] a16, b16; wire [15:0] s16; wire c16;
    logic cin;
    adder_n #(.N(8))  add8  (.a(a8),  .b(b8),  .cin, .sum(s8),  .cout(c8));
    adder_n #(.N(16)) add16 (.a(a16), .b(b16), .cin, .sum(s16), .cout(c16));

    // a decade counter: 4 bits, wraps after 9
    wire [3:0] dec; wire dec_wrap;
    counter_n #(.WIDTH(4), .MAX(9)) cnt10 (.clk, .rst_n, .en, .count(dec), .wrap(dec_wrap));

    wire [7:0] q;
    shift_reg #(.N(8)) sr (.clk, .rst_n, .din, .q);

    always #5 clk = ~clk;

    initial begin
        for (int t = 0; t < 2000; t++) begin
            a8 = $urandom; b8 = $urandom; a16 = $urandom; b16 = $urandom; cin = $urandom;
            #1;
            if ({c8, s8}   !== a8 + b8 + cin)   errors++;
            if ({c16, s16} !== a16 + b16 + cin) errors++;
        end
        if (errors) $display("adder errors: %0d", errors);

        repeat (2) @(posedge clk);
        @(negedge clk) begin rst_n = 1; en = 1; end
        for (int k = 1; k <= 35; k++) begin
            @(negedge clk) din = k[0] ^ k[2];
            if (dec !== 4'(k % 10)) begin
                $display("decade counter: %0d after %0d edges", dec, k);
                errors++;
            end
        end
        if (errors == 0) $display("PASS: adders (8 and 16 bit) and decade counter correct");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule

`default_nettype wire
