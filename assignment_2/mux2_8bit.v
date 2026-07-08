`timescale 1ns/1ps

module mux2_8bit (
    input  wire [7:0] in0,
    input  wire [7:0] in1,
    input  wire       select,
    output wire [7:0] out
);

    assign out = (select == 1'b0) ? in0 : in1;

endmodule
