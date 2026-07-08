`timescale 1ns/1ps

//NOTE: This module does not do much computation itself
//It's job is to wire the submodules together. 
module processor_top (
    input  wire       clk,
    input  wire       reset,
    output wire [7:0] aluresult,
    output wire [7:0] pc
);

    wire [31:0] instruction;

    program_counter PC_UNIT (
        .clk(clk),
        .reset(reset),
        .pc(pc)
    );

    instruction_memory IMEM (
        .pc(pc),
        .instruction(instruction)
    );

    cpu CPU_UNIT (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .aluresult(aluresult)
    );

endmodule
