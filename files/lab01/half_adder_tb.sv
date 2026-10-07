// Lesson 1: self-checking testbench for half_adder.
// A testbench is ordinary Verilog that is never built into hardware.
// It drives inputs, waits, and checks the outputs.
`timescale 1ns/1ps
`default_nettype none

module half_adder_tb;
    logic a, b;          // signals we drive
    wire  sum, carry;    // signals the design drives
    int   errors = 0;

    half_adder dut (.a(a), .b(b), .sum(sum), .carry(carry));

    initial begin
        $dumpfile("dump.vcd");          // record every signal for the waveform viewer
        $dumpvars(0, half_adder_tb);

        for (int i = 0; i < 4; i++) begin
            {a, b} = i[1:0];            // try 00, 01, 10, 11
            #10;                        // wait 10 ns for the logic to settle
            $display("a=%b b=%b -> carry=%b sum=%b", a, b, carry, sum);
            if ({carry, sum} !== a + b) begin
                $display("  MISMATCH: expected %0d", a + b);
                errors++;
            end
        end

        if (errors == 0) $display("PASS: all 4 cases correct");
        else             $display("FAIL: %0d case(s) wrong", errors);
        $finish;
    end
endmodule

`default_nettype wire
