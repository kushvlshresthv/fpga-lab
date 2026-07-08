`timescale 1ns/1ps

module alu (
    input  wire [7:0] operand1,
    input  wire [7:0] operand2,
    input  wire [2:0] aluop,
    output reg  [7:0] result
);

    localparam ALU_FORWARD = 3'b000;
    localparam ALU_ADD     = 3'b001;
    localparam ALU_SUB     = 3'b010;
    localparam ALU_AND     = 3'b011;
    localparam ALU_OR      = 3'b100;
    localparam ALU_XOR     = 3'b101;
    localparam ALU_SLL     = 3'b110;
    localparam ALU_SRL     = 3'b111;

    always @(*) begin
        case (aluop)

            ALU_FORWARD: begin
                result = operand1;
            end

            ALU_ADD: begin
                result = operand1 + operand2;
            end

            ALU_SUB: begin
                result = operand2 - operand1;
            end

            ALU_AND: begin
                result = operand1 & operand2;
            end

            ALU_OR: begin
                result = operand1 | operand2;
            end

            ALU_XOR: begin
                result = operand1 ^ operand2;
            end

            ALU_SLL: begin
                result = operand2 << operand1[2:0];
            end

            ALU_SRL: begin
                result = operand2 >> operand1[2:0];
            end

            default: begin
                result = 8'd0;
            end

        endcase
    end
endmodule
