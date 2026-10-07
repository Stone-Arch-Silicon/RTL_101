// Lesson 7 exercise solution.
`timescale 1ns/1ps
`default_nettype none

module gray2bin #(parameter int W = 8) (
    input  wire  [W-1:0] gray,
    output logic [W-1:0] bin
);
    always_comb begin
        bin[W-1] = gray[W-1];
        for (int i = W - 2; i >= 0; i--) bin[i] = bin[i+1] ^ gray[i];
    end
endmodule

`default_nettype wire
