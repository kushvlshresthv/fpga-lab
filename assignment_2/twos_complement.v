`timescale 1ns/1ps
module twos_complement (
    input  wire [7:0] in,
    output wire [7:0] out
);

    //twos complement = one's complement + 1
    assign out = ~in + 8'd1;

endmodule

