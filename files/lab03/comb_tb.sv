// Lesson 3: exhaustive check of mux4 (4-bit data) and decoder2to4.
`timescale 1ns/1ps
`default_nettype none

module comb_tb;
    logic [3:0] d0, d1, d2, d3;
    logic [1:0] sel, in;
    logic       en;
    wire  [3:0] y, out;
    int errors = 0;

    mux4 #(.W(4)) u_mux (.d0, .d1, .d2, .d3, .sel, .y);
    decoder2to4   u_dec (.in, .en, .out);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, comb_tb);
        d0 = 4'hA; d1 = 4'h5; d2 = 4'h3; d3 = 4'hC;
        for (int s = 0; s < 4; s++) begin
            sel = s[1:0];
            #5;
            if (y !== (s == 0 ? d0 : s == 1 ? d1 : s == 2 ? d2 : d3)) begin
                $display("mux4 wrong for sel=%0d: y=%h", s, y);
                errors++;
            end
        end
        for (int e = 0; e < 2; e++) begin
            for (int k = 0; k < 4; k++) begin
                en = e[0]; in = k[1:0];
                #5;
                if (out !== (en ? 4'(1 << k) : 4'b0)) begin
                    $display("decoder wrong for en=%b in=%0d: out=%b", en, k, out);
                    errors++;
                end
            end
        end
        if (errors == 0) $display("PASS: mux4 and decoder2to4 correct");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule

`default_nettype wire
