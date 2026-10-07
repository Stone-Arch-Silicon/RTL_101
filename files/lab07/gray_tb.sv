// Lesson 7 exercise: checks both converters for every 8-bit value.
`timescale 1ns/1ps
`default_nettype none

module gray_tb;
    logic [7:0] b;
    wire  [7:0] g, back;
    logic [7:0] prev_g;
    int errors = 0;

    function automatic int ones(input logic [7:0] v);
        ones = 0;
        for (int k = 0; k < 8; k++) ones += v[k];
    endfunction

    bin2gray #(.W(8)) u_b2g (.bin(b), .gray(g));
    gray2bin #(.W(8)) u_g2b (.gray(g), .bin(back));

    initial begin
        for (int i = 0; i < 256; i++) begin
            b = i[7:0];
            #1;
            if (g !== (b ^ (b >> 1))) begin
                if (errors < 5) $display("bin2gray(%0d) = %b", b, g);
                errors++;
            end
            if (back !== b) begin
                if (errors < 5) $display("gray2bin(bin2gray(%0d)) = %0d", b, back);
                errors++;
            end
            if (i > 0 && ones(g ^ prev_g) != 1) begin
                if (errors < 5) $display("codes for %0d and %0d differ in more than one bit", i - 1, i);
                errors++;
            end
            prev_g = g;
        end
        if (errors == 0) $display("PASS: Gray conversions correct for all 256 values");
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule

`default_nettype wire
