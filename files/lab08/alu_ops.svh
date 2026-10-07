// Lesson 8: opcode values shared by the ALU and its testbench.
// `include this file inside a module so both sides agree on the numbers.
localparam logic [2:0] OP_ADD = 3'd0;   // y = a + b
localparam logic [2:0] OP_SUB = 3'd1;   // y = a - b
localparam logic [2:0] OP_AND = 3'd2;   // y = a & b
localparam logic [2:0] OP_OR  = 3'd3;   // y = a | b
localparam logic [2:0] OP_XOR = 3'd4;   // y = a ^ b
localparam logic [2:0] OP_SLL = 3'd5;   // y = a << b[2:0]
localparam logic [2:0] OP_SRL = 3'd6;   // y = a >> b[2:0]
localparam logic [2:0] OP_SLT = 3'd7;   // y = 1 if a < b as signed numbers, else 0
