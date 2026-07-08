`timescale 1ns/1ps

module program_counter (
    input  wire       clk,
    input  wire       reset,
    output reg  [7:0] pc
);

    //block runs when clk or reset has a rising edge
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 8'd0;
        end
        else begin
            pc <= pc + 8'd1;
        end
    end
endmodule
