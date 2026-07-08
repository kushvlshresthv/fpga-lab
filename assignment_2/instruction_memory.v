`timescale 1ns/1ps

module instruction_memory (
    input  wire [7:0]  pc,
    output reg  [31:0] instruction
);

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

    always @(*) begin
        case (pc)

            // LOADI R1, 10
            // R1 = 10
            8'd0: begin
                instruction = {OP_LOADI, 5'b00000, 3'd1, 8'b00000000, 8'd10};
            end

            // LOADI R2, 5
            // R2 = 5
            8'd1: begin
                instruction = {OP_LOADI, 5'b00000, 3'd2, 8'b00000000, 8'd5};
            end

            // ADD R3, R1, R2
            // R3 = R1 + R2 = 10 + 5 = 15
            8'd2: begin
                instruction = {OP_ADD, 5'b00000, 3'd3, 5'b00000, 3'd1, 5'b00000, 3'd2};
            end

            // SUB R4, R1, R2
            // R4 = R1 - R2 = 10 - 5 = 5
            8'd3: begin
                instruction = {OP_SUB, 5'b00000, 3'd4, 5'b00000, 3'd1, 5'b00000, 3'd2};
            end

            // MOV R5, R3
            // For your MOV design, source is READREG2.
            // R5 = R3 = 15
            8'd4: begin
                instruction = {OP_MOV, 5'b00000, 3'd5, 5'b00000, 3'd0, 5'b00000, 3'd3};
            end

            // AND R6, R1, R2
            // R6 = 10 & 5 = 00001010 & 00000101 = 00000000
            8'd5: begin
                instruction = {OP_AND, 5'b00000, 3'd6, 5'b00000, 3'd1, 5'b00000, 3'd2};
            end

            // OR R7, R1, R2
            // R7 = 10 | 5 = 00001010 | 00000101 = 00001111 = 15
            8'd6: begin
                instruction = {OP_OR, 5'b00000, 3'd7, 5'b00000, 3'd1, 5'b00000, 3'd2};
            end

            default: begin
                instruction = {OP_NOP, 24'd0};
            end

        endcase
    end

endmodule
