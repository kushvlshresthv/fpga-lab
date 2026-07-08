`timescale 1ns/1ps

module tb_processor_top;

    reg clk;
    reg reset;

    wire [7:0] aluresult;
    wire [7:0] pc;

    processor_top DUT (
        .clk(clk),
        .reset(reset),
        .aluresult(aluresult),
        .pc(pc)
    );

    // Clock generation: 10 ns period
    always begin
        #5 clk = ~clk;
    end

    initial begin
        $dumpfile("tb_processor_top.vcd");
        $dumpvars(0, tb_processor_top);

        clk = 1'b0;
        reset = 1'b1;

        #12;
        reset = 1'b0;

        // Run enough cycles for all instructions
        #100;

        $display("----------------------------------");
        $display("Final Register Values:");
        $display("R0 = %d", DUT.CPU_UNIT.RF.registers[0]);
        $display("R1 = %d", DUT.CPU_UNIT.RF.registers[1]);
        $display("R2 = %d", DUT.CPU_UNIT.RF.registers[2]);
        $display("R3 = %d", DUT.CPU_UNIT.RF.registers[3]);
        $display("R4 = %d", DUT.CPU_UNIT.RF.registers[4]);
        $display("R5 = %d", DUT.CPU_UNIT.RF.registers[5]);
        $display("R6 = %d", DUT.CPU_UNIT.RF.registers[6]);
        $display("R7 = %d", DUT.CPU_UNIT.RF.registers[7]);
        $display("----------------------------------");

        $finish;
    end

    always @(posedge clk) begin
        $display("Time=%0t PC=%d ALURESULT=%d", $time, pc, aluresult);
    end

endmodule
