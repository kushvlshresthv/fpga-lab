module rv32i_cpu (
    input  wire        clk,
    input  wire        reset,
    output reg  [31:0] pc,
    output wire [31:0] instruction,
    output wire [31:0] alu_result,
    output reg  [31:0] write_back_data,
    output reg         reg_write,
    output reg         mem_write
);
    localparam ALU_ADD  = 4'd0;
    localparam ALU_SUB  = 4'd1;
    localparam ALU_SLL  = 4'd2;
    localparam ALU_SLT  = 4'd3;
    localparam ALU_SLTU = 4'd4;
    localparam ALU_XOR  = 4'd5;
    localparam ALU_SRL  = 4'd6;
    localparam ALU_SRA  = 4'd7;
    localparam ALU_OR   = 4'd8;
    localparam ALU_AND  = 4'd9;

    wire [6:0] opcode = instruction[6:0];
    wire [4:0] rd     = instruction[11:7];
    wire [2:0] funct3 = instruction[14:12];
    wire [4:0] rs1    = instruction[19:15];
    wire [4:0] rs2    = instruction[24:20];
    wire [6:0] funct7 = instruction[31:25];

    wire [31:0] immediate;
    wire [31:0] read_data1;
    wire [31:0] read_data2;
    wire [31:0] memory_read_data;
    reg  [31:0] alu_operand_a;
    reg  [31:0] alu_operand_b;
    reg  [3:0]  alu_operation;
    reg  [31:0] next_pc;
    reg          branch_taken;

    instruction_memory imem (
        .address(pc),
        .instruction(instruction)
    );

    immediate_generator imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );

    register_file reg_file (
        .clk(clk),
        .reset(reset),
        .write_enable(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_back_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    alu execute_alu (
        .a(alu_operand_a),
        .b(alu_operand_b),
        .operation(alu_operation),
        .result(alu_result)
    );

    data_memory dmem (
        .clk(clk),
        .reset(reset),
        .write_enable(mem_write),
        .funct3(funct3),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(memory_read_data)
    );

    always @(*) begin
        reg_write      = 1'b0;
        mem_write      = 1'b0;
        alu_operand_a  = read_data1;
        alu_operand_b  = read_data2;
        alu_operation  = ALU_ADD;
        write_back_data = alu_result;
        branch_taken   = 1'b0;
        next_pc        = pc + 32'd4;

        case (opcode)
            7'b0110011: begin // R-type ALU
                reg_write = 1'b1;
                case (funct3)
                    3'b000: alu_operation = funct7[5] ? ALU_SUB : ALU_ADD;
                    3'b001: alu_operation = ALU_SLL;
                    3'b010: alu_operation = ALU_SLT;
                    3'b011: alu_operation = ALU_SLTU;
                    3'b100: alu_operation = ALU_XOR;
                    3'b101: alu_operation = funct7[5] ? ALU_SRA : ALU_SRL;
                    3'b110: alu_operation = ALU_OR;
                    3'b111: alu_operation = ALU_AND;
                    default: alu_operation = ALU_ADD;
                endcase
            end

            7'b0010011: begin // I-type ALU
                reg_write     = 1'b1;
                alu_operand_b = immediate;
                case (funct3)
                    3'b000: alu_operation = ALU_ADD;
                    3'b001: alu_operation = ALU_SLL;
                    3'b010: alu_operation = ALU_SLT;
                    3'b011: alu_operation = ALU_SLTU;
                    3'b100: alu_operation = ALU_XOR;
                    3'b101: alu_operation = instruction[30] ? ALU_SRA : ALU_SRL;
                    3'b110: alu_operation = ALU_OR;
                    3'b111: alu_operation = ALU_AND;
                    default: alu_operation = ALU_ADD;
                endcase
            end

            7'b0000011: begin // LB, LH, LW, LBU, LHU
                reg_write      = 1'b1;
                alu_operand_b  = immediate;
                alu_operation  = ALU_ADD;
                write_back_data = memory_read_data;
            end

            7'b0100011: begin // SB, SH, SW
                mem_write     = 1'b1;
                alu_operand_b = immediate;
                alu_operation = ALU_ADD;
            end

            7'b1100011: begin // Conditional branches
                alu_operation = ALU_SUB;
                case (funct3)
                    3'b000: branch_taken = (read_data1 == read_data2); // BEQ
                    3'b001: branch_taken = (read_data1 != read_data2); // BNE
                    3'b100: branch_taken = ($signed(read_data1) < $signed(read_data2)); // BLT
                    3'b101: branch_taken = ($signed(read_data1) >= $signed(read_data2)); // BGE
                    3'b110: branch_taken = (read_data1 < read_data2); // BLTU
                    3'b111: branch_taken = (read_data1 >= read_data2); // BGEU
                    default: branch_taken = 1'b0;
                endcase
                if (branch_taken)
                    next_pc = pc + immediate;
            end

            7'b0110111: begin // LUI
                reg_write       = 1'b1;
                write_back_data = immediate;
            end

            7'b0010111: begin // AUIPC
                reg_write       = 1'b1;
                write_back_data = pc + immediate;
            end

            7'b1101111: begin // JAL
                reg_write       = 1'b1;
                write_back_data = pc + 32'd4;
                next_pc         = pc + immediate;
            end

            7'b1100111: begin // JALR
                reg_write       = 1'b1;
                write_back_data = pc + 32'd4;
                next_pc         = (read_data1 + immediate) & 32'hffff_fffe;
            end

            default: ; // NOP for unsupported SYSTEM/FENCE/invalid instructions
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'd0;
        else
            pc <= next_pc;
    end
endmodule
