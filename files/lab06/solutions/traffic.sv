// Lesson 6 exercise solution: three states plus a shared timer.
`timescale 1ns/1ps
`default_nettype none

module traffic (
    input  wire        clk,
    input  wire        rst_n,
    output logic [2:0] lights
);
    localparam logic [2:0] RED = 3'b100, YELLOW = 3'b010, GREEN = 3'b001;

    typedef enum logic [1:0] {S_RED, S_GREEN, S_YELLOW} state_t;
    state_t state, next;
    logic [2:0] timer;            // counts cycles spent in the current state
    logic [2:0] last;             // timer value on the final cycle of this state

    always_comb begin
        case (state)
            S_RED:    last = 3'd3;   // 4 cycles: timer 0,1,2,3
            S_GREEN:  last = 3'd4;   // 5 cycles
            S_YELLOW: last = 3'd1;   // 2 cycles
            default:  last = 3'd0;
        endcase
    end

    always_comb begin
        next = state;
        if (timer == last) begin
            case (state)
                S_RED:    next = S_GREEN;
                S_GREEN:  next = S_YELLOW;
                S_YELLOW: next = S_RED;
                default:  next = S_RED;
            endcase
        end
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            state <= S_RED;
            timer <= 3'd0;
        end else begin
            state <= next;
            timer <= (timer == last) ? 3'd0 : timer + 3'd1;
        end
    end

    always_comb begin
        case (state)
            S_GREEN:  lights = GREEN;
            S_YELLOW: lights = YELLOW;
            default:  lights = RED;
        endcase
    end
endmodule

`default_nettype wire
