`timescale 1ns/1ps

module alu8_tb;

    // inputs to the ALU (must be "reg" because we drive them)
    reg [7:0] A;
    reg [7:0] B;
    reg [3:0] sel;

    // outputs from the ALU (must be "wire" because ALU drives them)
    wire [7:0] Result;
    wire Cout;
    wire Zero;
    wire Overflow;

    // connect our testbench signals to the ALU module
    alu8_dataflow dut (
        A,
        B,
        sel,
        Result,
        Cout,
        Zero,
        Overflow
    );

    // this just prints the current values nicely.
    task show_result;
        begin
            $display("sel=%b | A=%d B=%d | Result=%d | Cout=%b Zero=%b Overflow=%b",
                       sel, A, B, Result, Cout, Zero, Overflow);
        end
    endtask

    initial begin

        $display("---------- STARTING ALU TESTS ----------");

        // Test 1: ADD
        A = 20; B = 5; sel = 4'b0000;
        #10 show_result;

        // Test 2: SUBTRACT
        A = 20; B = 5; sel = 4'b0001;
        #10 show_result;

        // Test 3: AND
        A = 12; B = 10; sel = 4'b0010;
        #10 show_result;

        // Test 4: OR
        A = 12; B = 10; sel = 4'b0011;
        #10 show_result;

        // Test 5: XOR
        A = 12; B = 10; sel = 4'b0100;
        #10 show_result;

        // Test 6: NOT (only A matters here)
        A = 12; B = 0; sel = 4'b1000;
        #10 show_result;

        // Test 7: Shift left
        A = 8'b00001111; B = 0; sel = 4'b1001;
        #10 show_result;

        // Test 8: Shift right
        A = 8'b00001111; B = 0; sel = 4'b1010;
        #10 show_result;

        // Test 9: Rotate left
        A = 8'b10000001; B = 0; sel = 4'b1011;
        #10 show_result;

        // Test 10: Rotate right
        A = 8'b10000001; B = 0; sel = 4'b1100;
        #10 show_result;

        // Test 11: Multiply
        A = 6; B = 7; sel = 4'b1101;
        #10 show_result;

        // Test 12: Greater than
        A = 50; B = 20; sel = 4'b1110;
        #10 show_result;

        // Test 13: Equal to
        A = 33; B = 33; sel = 4'b1111;
        #10 show_result;

        $display("---------- CHECKING CARRY / OVERFLOW ----------");

        // Test 14: carry out should be 1 (255 + 1 wraps around to 0)
        A = 255; B = 1; sel = 4'b0000;
        #10 show_result;

        // Test 15: borrow should set carry (10 - 20 is negative)
        A = 10; B = 20; sel = 4'b0001;
        #10 show_result;

        // Test 16: signed overflow (127 + 1 overflows in signed math)
        A = 127; B = 1; sel = 4'b0000;
        #10 show_result;

        // Test 17: zero flag check (5 - 5 = 0)
        A = 5; B = 5; sel = 4'b0001;
        #10 show_result;

        $display("---------- TESTS DONE ----------");

        $finish;
    end

endmodule
