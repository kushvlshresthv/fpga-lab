`timescale 1ns/1ps

module register_file (
    input  wire        clk,
    input  wire        reset,

    input  wire [2:0]  readreg1,
    input  wire [2:0]  readreg2,
    input  wire [2:0]  writereg,

    input  wire [7:0]  writedata,
    input  wire        writeenable,

    output wire [7:0]  regout1,
    output wire [7:0]  regout2
);

    //NOTE: [7:0] before the name `registers` describes the value width
    //NOTE: [0:7] after the name `registers` describes the numbers of regs
    reg [7:0] registers [0:7];

    integer i;

    // Asynchronous read
    assign regout1 = registers[readreg1];
    assign regout2 = registers[readreg2];

    // Synchronous write and reset
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1) begin
                registers[i] <= 8'd0;
            end
        end
        else begin
            if (writeenable) begin
                registers[writereg] <= writedata;
            end
        end
    end

endmodule
