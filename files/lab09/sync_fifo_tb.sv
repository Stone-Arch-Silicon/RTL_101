// Lesson 9 exercise: random pushes and pops against a queue model.
`timescale 1ns/1ps
`default_nettype none

module sync_fifo_tb;
    logic clk = 0, rst_n = 0, wr_en = 0, rd_en = 0;
    logic [7:0] wr_data = 0;
    wire  [7:0] rd_data;
    wire        full, empty;
    wire  [3:0] count;
    logic [7:0] model [$];          // a SystemVerilog queue: grows and shrinks
    int errors = 0, pushes = 0, pops = 0, fulls = 0;
    bit will_push, will_pop;        // what the FIFO should do at the next edge

    sync_fifo #(.WIDTH(8), .DEPTH(8)) dut (.*);

    always #5 clk = ~clk;

    task automatic check(input string what, input logic ok);
        if (!ok) begin
            if (errors < 6) $display("t=%0t %s (model holds %0d)", $time, what, model.size());
            errors++;
        end
    endtask

    initial begin
        repeat (2) @(posedge clk);
        @(negedge clk) rst_n = 1;
        repeat (4000) begin
            @(negedge clk);
            // flags and data must agree with the model before the next edge
            check("empty flag wrong", empty === (model.size() == 0));
            check("full flag wrong",  full  === (model.size() == 8));
            check("count wrong",      count === 4'(model.size()));
            if (model.size() > 0) check("rd_data wrong", rd_data === model[0]);
            fulls += full;
            // bias toward writing for a while, then toward reading
            wr_en   = ($urandom_range(0, 99) < (($time / 20000) % 2 ? 30 : 70));
            rd_en   = ($urandom_range(0, 99) < (($time / 20000) % 2 ? 70 : 30));
            wr_data = $urandom;
            // decide what the FIFO should do at the coming edge (same rules as the design)
            will_pop  = rd_en && (model.size() > 0);
            will_push = wr_en && (model.size() < 8);   // a full FIFO ignores pushes
            @(posedge clk);
            if (will_pop)  begin void'(model.pop_front()); pops++;   end
            if (will_push) begin model.push_back(wr_data); pushes++; end
        end
        if (errors == 0) $display("PASS: %0d pushes, %0d pops, full seen on %0d cycles, no errors", pushes, pops, fulls);
        else             $display("FAIL: %0d errors", errors);
        $finish;
    end
endmodule

`default_nettype wire
