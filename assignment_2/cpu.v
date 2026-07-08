`timescale 1ns/1ps

// This cpu moduel connects the CPU's main internal parts ie the control unit,
// register file, two's complement unit, multplexers, and ALU(based on diagram)
module cpu (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] instruction,

    output wire [7:0]  aluresult
);

    wire [2:0] readreg1;
    wire [2:0] readreg2;
    wire [2:0] writereg;
    wire       writeenable;

    wire [7:0] immediate;
    wire [2:0] aluop;

    wire       mux_reg2_select;
    wire       mux_imm_select;

    wire [7:0] regout1;
    wire [7:0] regout2;
    wire [7:0] regout2_twos;
    wire [7:0] mux_reg2_out;

    wire [7:0] operand1;
    wire [7:0] operand2;

    control_unit cu (
        .instruction(instruction),

        .readreg1(readreg1),
        .readreg2(readreg2),
        .writereg(writereg),
        .writeenable(writeenable),

        .immediate(immediate),
        .aluop(aluop),

        .mux_reg2_select(mux_reg2_select),
        .mux_imm_select(mux_imm_select)
    );

    register_file rf (
        .clk(clk),
        .reset(reset),

        .readreg1(readreg1),
        .readreg2(readreg2),
        .writereg(writereg),

        .writedata(aluresult),
        .writeenable(writeenable),

        .regout1(regout1),
        .regout2(regout2)
    );

    twos_complement tc (
        .in(regout2),
        .out(regout2_twos)
    );

    mux2_8bit mux_reg2 (
        .in0(regout2),
        .in1(regout2_twos),
        .select(mux_reg2_select),
        .out(mux_reg2_out)
    );

    mux2_8bit mux_imm (
        .in0(mux_reg2_out),
        .in1(immediate),
        .select(mux_imm_select),
        .out(operand1)
    );

    assign operand2 = regout1;

    alu alu (
        .operand1(operand1),
        .operand2(operand2),
        .aluop(aluop),
        .result(aluresult)
    );

endmodule
