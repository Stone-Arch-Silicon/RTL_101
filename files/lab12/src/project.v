/*
 * Lesson 12 capstone starting point: an 8-bit PWM generator for Tiny Tapeout.
 * SPDX-License-Identifier: Apache-2.0
 *
 * ui_in[7:0]   duty cycle, 0 to 255 (number of high cycles out of every 256)
 * uo_out[0]    PWM output
 * uo_out[1]    PWM output, inverted
 * uo_out[7:2]  top six bits of the period counter, so you can watch it run
 * uio          not used (all set as inputs)
 */
`default_nettype none

module tt_um_sasi_pwm (
    input  wire [7:0] ui_in,    // dedicated inputs
    output wire [7:0] uo_out,   // dedicated outputs
    input  wire [7:0] uio_in,   // bidirectional pins: input path
    output wire [7:0] uio_out,  // bidirectional pins: output path
    output wire [7:0] uio_oe,   // bidirectional pins: 1 = drive the pin
    input  wire       ena,      // 1 when this design is selected on the chip
    input  wire       clk,      // clock
    input  wire       rst_n     // reset, active low
);
    reg [7:0] count;            // free-running period counter
    reg [7:0] duty;             // duty value captured once per period
    reg       pwm;

    always @(posedge clk) begin
        if (!rst_n) begin
            count <= 8'd0;
            duty  <= 8'd0;
            pwm   <= 1'b0;
        end else begin
            count <= count + 8'd1;
            if (count == 8'd255) duty <= ui_in;   // only change duty between periods
            pwm <= (count < duty);
        end
    end

    assign uo_out  = {count[7:2], ~pwm, pwm};
    assign uio_out = 8'd0;
    assign uio_oe  = 8'd0;

    // tell the linter that these inputs are intentionally unused
    wire _unused = &{ena, uio_in, 1'b0};
endmodule
