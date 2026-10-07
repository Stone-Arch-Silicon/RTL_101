// Lesson 3 exercise: checks adder4 for all 512 combinations of a, b, cin.
`timescale 1ns/1ps
`default_nettype none

module adder4_tb;
    logic [3:0] a, b;
    logic       cin;
    wire  [3:0] sum;
    wire        cout;
    int errors = 0;

    adder4 dut (.a, .b, .cin, .sum, .cout);

    initial begin
        for (int i = 0; i < 512; i++) begin
            {a, b, cin} = i[8:0];
            #2;
            if ({cout, sum} !== a + b + cin) begin
                if (errors < 8) $display("%0d + %0d + %0d gave %0d", a, b, cin, {cout, sum});
                errors++;
            end
        end
        if (errors == 0) $display("PASS: all 512 cases correct");
        else             $display("FAIL: %0d wrong", errors);
        $finish;
    end
endmodule

`default_nettype wire
