`timescale 1ns/1ps

/*
 * Given a 32-bit instruction, the control unit should extract: 
 * READREG1[2:0]
 * READREG2[2:0]
 * WRITEREG[2:0]
 * IMMEDIATE[7:0]
 * ALUOP[7:0]
 * WRITEENABLE
 * MUX selections
 *
 *
 * We will assume this simple instruction format; 
 * Instruction[31:24] = OPCODE
 * Instruction[23:19] = unused
 * Instruction[18:16] = WRITEREG
 * Instruction[15:11] = unusd
 * Instruction[10:8]  = READREG1
 * Instruction[7:3]   = unused/immediate upper bits
 * Instruction[2:0]   = READREG2
 * Instruction[7:0]   = Immediate value
 * 
 * We will support these instructions first: 
 *
 * LOADI -> write immediate to register
 * MOV   -> copy one register to another
 * ADD   -> add two registers
 * SUB   -> subtract two registers
 * AND   -> bitwise AND
 * OR    -> bitwise OR
 */



module control_unit (
    input  wire [31:0] instruction,

    output reg  [2:0] readreg1,
    output reg  [2:0] readreg2,
    output reg  [2:0] writereg,
    output reg        writeenable,

    output reg  [7:0] immediate,
    output reg  [2:0] aluop,

    output reg        mux_reg2_select,
    output reg        mux_imm_select
);

    // Opcode definitions
    localparam OP_LOADI = 8'b00000000;
    localparam OP_MOV   = 8'b00000001;
    localparam OP_ADD   = 8'b00000010;
    localparam OP_SUB   = 8'b00000011;
    localparam OP_AND   = 8'b00000100;
    localparam OP_OR    = 8'b00000101;
    localparam OP_XOR   = 8'b00000110;
    localparam OP_SLL   = 8'b00000111;
    localparam OP_SRL   = 8'b00001000;
    localparam OP_NOP   = 8'b11111111;

    // ALU operation definitions
    localparam ALU_FORWARD = 3'b000; //just forward the input
    localparam ALU_ADD     = 3'b001;
    localparam ALU_SUB     = 3'b010;
    localparam ALU_AND     = 3'b011;
    localparam ALU_OR      = 3'b100;
    localparam ALU_XOR     = 3'b101;
    localparam ALU_SLL     = 3'b110;
    localparam ALU_SRL     = 3'b111;

    wire [7:0] opcode;

    assign opcode = instruction[31:24];

    always @(*) begin
        // Default values
        readreg1        = instruction[10:8];
        readreg2        = instruction[2:0];
        writereg        = instruction[18:16];
        immediate       = instruction[7:0];

        writeenable     = 1'b0;
        aluop           = ALU_FORWARD;

        mux_reg2_select = 1'b0;
        mux_imm_select  = 1'b0;

        case (opcode)

            /*
             * First the immediate value is made available to the ALU
             * because mux_imm_select is 1
             * ALU just outputs that value to 8x8 register file
             * due to writeenable, WRITEREG register is written with ALU's o/p
            */
            OP_LOADI: begin
                writeenable     = 1'b1;
                aluop           = ALU_FORWARD;
                mux_imm_select  = 1'b1;
                mux_reg2_select = 1'b0;
            end

            /*
             * REGOUT1 is the 8-bit value read from READREG1.
             * REGOUT2 is the 8-bit value read from READREG2.
             *
             * In the given datapath, REGOUT2 goes through the mux path
             * and reaches the upper ALU input.
             *
             * Since mux_imm_select = 0, the mux selects REGOUT2 instead of IMMEDIATE.
             * Since mux_reg2_select = 0, REGOUT2 is sent without two's complement.
             *
             * ALU_FORWARD forwards the upper ALU input.
             * Since writeenable is high, the ALU output is written to WRITEREG.
             *
             * Effectively, the value stored in the register selected by READREG2
             * is copied into the register selected by WRITEREG.
             *
             * Example:
             * MOV R1, R2 means R1 = R2
             */

            OP_MOV: begin
                writeenable     = 1'b1;
                aluop           = ALU_FORWARD;
                mux_imm_select  = 1'b0;
                mux_reg2_select = 1'b0;
            end

            /*
            * REGOUT1 and REGOUT2 is fed to the ALU
            * ALU mode is set to ADD
            * o/p of ALU writted to WRITEREG as writeenable is high
            */
            OP_ADD: begin
                writeenable     = 1'b1;
                aluop           = ALU_ADD;
                mux_imm_select  = 1'b0;
                mux_reg2_select = 1'b0;
            end

            /*
            * REGOUT1 and REGOUT2's 2's complement is fed to the ALU
            * ALU mode is set to SUBTRACT
            * o/p of ALU writted to WRITEREG as writeenable is high
            */

            OP_SUB: begin
                writeenable     = 1'b1;
                aluop           = ALU_ADD;
                mux_imm_select  = 1'b0;
                mux_reg2_select = 1'b1;
            end


            /*
            * REGOUT1 and REGOUT2 is fed to the ALU
            * ALU mode is set to AND
            * o/p of ALU writted to WRITEREG as writeenable is high
            */
            OP_AND: begin
                writeenable     = 1'b1;
                aluop           = ALU_AND;
                mux_imm_select  = 1'b0;
                mux_reg2_select = 1'b0;
            end


            /*
            * REGOUT1 and REGOUT2 is fed to the ALU
            * ALU mode is set to OR
            * o/p of ALU writted to WRITEREG as writeenable is high
            */
            OP_OR: begin
                writeenable     = 1'b1;
                aluop           = ALU_OR;
                mux_imm_select  = 1'b0;
                mux_reg2_select = 1'b0;
            end

            OP_XOR: begin
                writeenable     = 1'b1;
                aluop           = ALU_XOR;
                mux_imm_select  = 1'b0;
                mux_reg2_select = 1'b0;
            end

            OP_SLL: begin
                writeenable     = 1'b1;
                aluop           = ALU_SLL;
                mux_imm_select  = 1'b0;
                mux_reg2_select = 1'b0;
            end

            OP_SRL: begin
                writeenable     = 1'b1;
                aluop           = ALU_SRL;
                mux_imm_select  = 1'b0;
                mux_reg2_select = 1'b0;
            end

            OP_NOP: begin
                writeenable     = 1'b0;
                aluop           = ALU_FORWARD;
                mux_imm_select  = 1'b0;
                mux_reg2_select = 1'b0;
            end

            default: begin
                writeenable     = 1'b0;
                aluop           = ALU_FORWARD;
                mux_imm_select  = 1'b0;
                mux_reg2_select = 1'b0;
            end

        endcase
    end

endmodule
