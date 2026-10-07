// Lesson 2: predict each line before you run this file.
// Run with: make predict
`timescale 1ns/1ps
`default_nettype none

module predict_tb;
    logic [3:0] a4;
    logic [4:0] s5;
    logic [7:0] s8;
    logic [7:0] u8;
    logic signed [7:0] sg8;

    initial begin
        // 1. Two 4-bit numbers added inside a 4-bit expression
        $display("1:  %b", 4'b1010 + 4'b0111);
        // 2. The same sum stored into a 5-bit variable
        s5 = 4'b1010 + 4'b0111;
        $display("2:  %b (%0d)", s5, s5);
        // 3. 200 + 100 stored into 8 bits
        s8 = 8'd200 + 8'd100;
        $display("3:  %0d", s8);
        // 4. Negative three as an 8-bit pattern
        sg8 = -8'sd3;
        $display("4:  %b", sg8);
        // 5. Logical shift right of an unsigned value
        u8 = 8'hF0;
        $display("5:  %h", u8 >> 2);
        // 6. Arithmetic shift right of a signed value
        sg8 = 8'shF0;
        $display("6:  %h", sg8 >>> 2);
        // 7. Reduction operators: AND, OR, XOR of all bits
        a4 = 4'b1011;
        $display("7:  &=%b |=%b ^=%b", &a4, |a4, ^a4);
        // 8. Concatenation and replication
        $display("8:  %b", {2'b10, {3{2'b01}}});
        // 9. Bitwise AND with an unknown bit
        $display("9:  %b", 4'b1x01 & 4'b0101);
        // 10. == versus === when a bit is unknown
        $display("10: %b %b", 4'b10x0 == 4'b1000, 4'b10x0 === 4'b1000);
        // 11. The same bits compared as unsigned and as signed
        u8 = 8'hFF;
        $display("11: %b %b", u8 < 8'd1, $signed(u8) < 8'sd1);
        // 12. Part select and bit select
        u8 = 8'b1100_0101;
        $display("12: %b %b", u8[7:4], u8[0]);
        $finish;
    end
endmodule

`default_nettype wire
