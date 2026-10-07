// Lesson 4 exercise: checks prio_enc for all 256 request patterns.
`timescale 1ns/1ps
`default_nettype none

module prio_enc_tb;
    logic [7:0] req;
    wire  [2:0] idx;
    wire        valid;
    int errors = 0;

    prio_enc dut (.req, .idx, .valid);

    initial begin
        for (int i = 0; i < 256; i++) begin
            int exp_idx;
            req = i[7:0];
            #1;
            exp_idx = 0;
            for (int k = 0; k < 8; k++) if (req[k]) exp_idx = k;
            if (valid !== (req != 0) || idx !== 3'(exp_idx)) begin
                if (errors < 8) $display("req=%b: got idx=%0d valid=%b, expected idx=%0d valid=%b",
                                         req, idx, valid, exp_idx, req != 0);
                errors++;
            end
        end
        if (errors == 0) $display("PASS: all 256 patterns correct");
        else             $display("FAIL: %0d wrong", errors);
        $finish;
    end
endmodule

`default_nettype wire
