// Lesson 6 exercise: traffic light controller.
// lights = {red, yellow, green}; exactly one bit is 1 at any time.
// While rst_n is 0 the light is red. After reset is released:
//   red stays on for 4 clock cycles, then green for 5, then yellow for 2,
//   then red for 4 again, and so on forever.
`timescale 1ns/1ps
`default_nettype none

module traffic (
    input  wire        clk,
    input  wire        rst_n,
    output logic [2:0] lights
);
    localparam logic [2:0] RED = 3'b100, YELLOW = 3'b010, GREEN = 3'b001;

    // TODO: an enum for the three states, a timer register,
    // a state register, next-state logic, and the lights output.
    assign lights = RED;
endmodule

`default_nettype wire
