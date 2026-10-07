// Lesson 1 exercise: checks full_adder against a + b + cin for all 8 input patterns.
`timescale 1ns/1ps
`default_nettype none

module full_adder_tb;
    logic a, b, cin;
    wire  sum, cout;
    int   errors = 0;

    full_adder dut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, full_adder_tb);
        for (int i = 0; i < 8; i++) begin
            {a, b, cin} = i[2:0];
            #10;
            if ({cout, sum} !== a + b + cin) begin
                $display("MISMATCH a=%b b=%b cin=%b: got cout=%b sum=%b, expected %02b",
                         a, b, cin, cout, sum, a + b + cin);
                errors++;
            end
        end
        if (errors == 0) $display("PASS: all 8 cases correct");
        else             $display("FAIL: %0d case(s) wrong", errors);
        $finish;
    end
endmodule

`default_nettype wire
