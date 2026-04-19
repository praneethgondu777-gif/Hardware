`ifndef OPCODE_VH
`define OPCODE_VH

// --- MAU Custom Opcode ---
`define OPCODE_CUSTOM 7'b0001011
`define FUNCT7_MAU    7'b0000001

// --- MAU funct3 Definitions ---
`define F3_ABS        3'b000
`define F3_MAX        3'b001
`define F3_MIN        3'b010
`define F3_SQRT       3'b011
`define F3_LOG2       3'b100

`endif