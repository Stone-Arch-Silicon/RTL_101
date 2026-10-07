// Lesson 4: draws every digit in the terminal so you can check it by eye,
// and compares against a reference table.
`timescale 1ns/1ps
`default_nettype none

module hex7seg_tb;
    logic [3:0] hex;
    wire  [6:0] seg;
    int errors = 0;

    hex7seg dut (.hex, .seg);

    // reference patterns, written as hex numbers instead of a case statement
    function automatic logic [6:0] expected(input logic [3:0] h);
        case (h)
            4'h0: return 7'h3F;  4'h1: return 7'h06;  4'h2: return 7'h5B;  4'h3: return 7'h4F;
            4'h4: return 7'h66;  4'h5: return 7'h6D;  4'h6: return 7'h7D;  4'h7: return 7'h07;
            4'h8: return 7'h7F;  4'h9: return 7'h6F;  4'hA: return 7'h77;  4'hB: return 7'h7C;
            4'hC: return 7'h39;  4'hD: return 7'h5E;  4'hE: return 7'h79;  default: return 7'h71;
        endcase
    endfunction

    initial begin
        for (int i = 0; i < 16; i++) begin
            hex = i[3:0];
            #1;
            $display("digit %h", hex);
            $display(" %s ",    seg[0] ? "___" : "   ");
            $display("%s   %s", seg[5] ? "|" : " ", seg[1] ? "|" : " ");
            $display(" %s ",    seg[6] ? "---" : "   ");
            $display("%s   %s", seg[4] ? "|" : " ", seg[2] ? "|" : " ");
            $display(" %s ",    seg[3] ? "___" : "   ");
            if (seg !== expected(hex)) begin
                $display("  MISMATCH: got %b expected %b", seg, expected(hex));
                errors++;
            end
        end
        if (errors == 0) $display("PASS: all 16 digits correct");
        else             $display("FAIL: %0d digits wrong", errors);
        $finish;
    end
endmodule

`default_nettype wire
