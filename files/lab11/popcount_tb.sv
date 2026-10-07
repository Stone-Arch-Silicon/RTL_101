// Lesson 11: both versions must agree with each other for all 65,536 inputs.
`timescale 1ns/1ps
`default_nettype none

module popcount_tb;
    logic [15:0] x;
    wire  [4:0]  c_loop, c_tree;
    int errors = 0;

    popcount_loop u_loop (.x, .count(c_loop));
    popcount_tree u_tree (.x, .count(c_tree));

    initial begin
        for (int i = 0; i < 65536; i++) begin
            int ones;
            x = i[15:0];
            #1;
            ones = 0;
            for (int k = 0; k < 16; k++) ones += x[k];
            if (c_loop !== 5'(ones) || c_tree !== 5'(ones)) begin
                if (errors < 5) $display("x=%h: loop=%0d tree=%0d expected %0d", x, c_loop, c_tree, ones);
                errors++;
            end
        end
        if (errors == 0) $display("PASS: both popcounts correct for all 65536 inputs");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule

`default_nettype wire
