// Lesson 2 exercise: checks bit_tricks for all 256 inputs.
`timescale 1ns/1ps
`default_nettype none

module bit_tricks_tb;
    logic [7:0]  x;
    wire         is_neg, parity, all_ones;
    wire  [7:0]  negated, swapped;
    wire  [15:0] sext;
    int errors = 0;

    bit_tricks dut (.*);

    function automatic int ones(input logic [7:0] v);
        ones = 0;
        for (int k = 0; k < 8; k++) ones += v[k];
    endfunction

    task automatic check(input string name, input logic [15:0] got, input logic [15:0] exp);
        if (got !== exp) begin
            if (errors < 10) $display("x=%h %-8s got %h expected %h", x, name, got, exp);
            errors++;
        end
    endtask

    initial begin
        for (int i = 0; i < 256; i++) begin
            x = i[7:0];
            #1;
            check("is_neg",   16'(is_neg),   16'(x >= 8'd128));
            check("negated",  16'(negated),  16'((256 - i) % 256));
            check("parity",   16'(parity),   16'(ones(x) % 2));
            check("all_ones", 16'(all_ones), 16'(x == 8'hFF));
            check("swapped",  16'(swapped),  16'({x[3:0], x[7:4]}));
            check("sext",     sext,          (i >= 128) ? 16'(i) | 16'hFF00 : 16'(i));
        end
        if (errors == 0) $display("PASS: all 256 inputs correct");
        else             $display("FAIL: %0d mismatches", errors);
        $finish;
    end
endmodule

`default_nettype wire
