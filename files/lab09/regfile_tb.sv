// Lesson 9: random writes and reads, checked against a model array.
`timescale 1ns/1ps
`default_nettype none

module regfile_tb;
    logic clk = 0, we = 0;
    logic [2:0] waddr = 0, raddr_a = 0, raddr_b = 0;
    logic [7:0] wdata = 0;
    wire  [7:0] rdata_a, rdata_b;
    logic [7:0] model [8];
    int errors = 0;

    regfile dut (.*);

    always #5 clk = ~clk;

    initial begin
        // write every register once so nothing is unknown
        for (int r = 0; r < 8; r++) begin
            @(negedge clk) begin we = 1; waddr = r[2:0]; wdata = 8'(r * 17); end
            @(posedge clk) model[r] = 8'(r * 17);
        end
        repeat (1000) begin
            @(negedge clk);
            we = $urandom_range(0, 1);
            waddr = $urandom; wdata = $urandom;
            raddr_a = $urandom; raddr_b = $urandom;
            #1;
            if (rdata_a !== model[raddr_a] || rdata_b !== model[raddr_b]) begin
                if (errors < 5) $display("read mismatch at r%0d/r%0d", raddr_a, raddr_b);
                errors++;
            end
            @(posedge clk) if (we) model[waddr] = wdata;
        end
        if (errors == 0) $display("PASS: 1000 random cycles, reads always matched");
        else             $display("FAIL: %0d mismatches", errors);
        $finish;
    end
endmodule

`default_nettype wire
