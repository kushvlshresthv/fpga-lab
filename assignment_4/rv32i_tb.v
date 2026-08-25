`timescale 1ns/1ps

module rv32i_tb;
    reg clk;
    reg reset;
    integer errors;

    wire [31:0] pc;
    wire [31:0] instruction;
    wire [31:0] alu_result;
    wire [31:0] write_back_data;
    wire reg_write;
    wire mem_write;

    // Convenient aliases for the waveform viewer.
    wire [31:0] x1  = dut.reg_file.registers[1];
    wire [31:0] x2  = dut.reg_file.registers[2];
    wire [31:0] x3  = dut.reg_file.registers[3];
    wire [31:0] x19 = dut.reg_file.registers[19];
    wire [31:0] x24 = dut.reg_file.registers[24];
    wire [31:0] data_word_0 = {dut.dmem.memory[3], dut.dmem.memory[2],
                               dut.dmem.memory[1], dut.dmem.memory[0]};

    rv32i_cpu dut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instruction(instruction),
        .alu_result(alu_result),
        .write_back_data(write_back_data),
        .reg_write(reg_write),
        .mem_write(mem_write)
    );

    always #5 clk = ~clk;

    task check_register;
        input integer index;
        input [31:0] expected;
        begin
            if (dut.reg_file.registers[index] !== expected) begin
                $display("FAIL: x%0d = 0x%08h, expected 0x%08h",
                         index, dut.reg_file.registers[index], expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        errors = 0;

        $dumpfile("wave.vcd");
        $dumpvars(0, rv32i_tb);

        #12 reset = 1'b0;
        repeat (58) @(posedge clk);
        #1;

        check_register(0,  32'd0);
        check_register(1,  32'd5);
        check_register(2,  32'd10);
        check_register(3,  32'd15);
        check_register(4,  32'd5);
        check_register(5,  32'd0);
        check_register(6,  32'd15);
        check_register(7,  32'd15);
        check_register(8,  32'd160);
        check_register(9,  32'd5);
        check_register(10, 32'd1);
        check_register(11, 32'd0);
        check_register(12, 32'd6);
        check_register(13, 32'd9);
        check_register(14, 32'd12);
        check_register(15, 32'd20);
        check_register(16, 32'd10);
        check_register(17, 32'hfffffff0);
        check_register(18, 32'hfffffffc);
        check_register(19, 32'd15);
        check_register(20, 32'hfffffff0);
        check_register(21, 32'd240);
        check_register(22, 32'hfffffff0);
        check_register(23, 32'h0000fff0);
        check_register(24, 32'd4);
        check_register(25, 32'h12345000);
        check_register(26, 32'h000010a4);
        check_register(27, 32'h000000ac);
        check_register(28, 32'd2);
        check_register(29, 32'd196);
        check_register(30, 32'd188);
        check_register(31, 32'd3);

        if (data_word_0 !== 32'd15) begin
            $display("FAIL: data memory word 0 = 0x%08h, expected 0x0000000f",
                     data_word_0);
            errors = errors + 1;
        end

        if (errors == 0)
            $display("PASS: all RV32I CPU checks completed successfully.");
        else
            $display("FAIL: %0d check(s) failed.", errors);

        $finish;
    end
endmodule
