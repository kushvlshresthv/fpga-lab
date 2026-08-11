`timescale 1ns/1ps

// 8-point radix-2 Decimation-In-Time FFT
// Integer inputs, fixed-point twiddle factor for 1/sqrt(2).
module fft_8point #(
    parameter IN_WIDTH  = 16,
    parameter OUT_WIDTH = 24
)(
    input  wire clk,
    input  wire rst,
    input  wire start,

    input  wire signed [8*IN_WIDTH-1:0] x_re,
    input  wire signed [8*IN_WIDTH-1:0] x_im,

    output reg done,
    output reg signed [OUT_WIDTH-1:0] X0_re, X0_im,
    output reg signed [OUT_WIDTH-1:0] X1_re, X1_im,
    output reg signed [OUT_WIDTH-1:0] X2_re, X2_im,
    output reg signed [OUT_WIDTH-1:0] X3_re, X3_im,
    output reg signed [OUT_WIDTH-1:0] X4_re, X4_im,
    output reg signed [OUT_WIDTH-1:0] X5_re, X5_im,
    output reg signed [OUT_WIDTH-1:0] X6_re, X6_im,
    output reg signed [OUT_WIDTH-1:0] X7_re, X7_im
);

    // Q14 representation of 0.70710678.
    localparam signed [15:0] C707 = 16'sd11585;

    localparam IDLE   = 3'd0;
    localparam STAGE1 = 3'd1;
    localparam STAGE2 = 3'd2;
    localparam STAGE3 = 3'd3;
    localparam OUTPUT = 3'd4;

    reg [2:0] state;
    integer i;

    reg signed [OUT_WIDTH-1:0] d_re  [0:7];
    reg signed [OUT_WIDTH-1:0] d_im  [0:7];
    reg signed [OUT_WIDTH-1:0] s1_re [0:7];
    reg signed [OUT_WIDTH-1:0] s1_im [0:7];
    reg signed [OUT_WIDTH-1:0] s2_re [0:7];
    reg signed [OUT_WIDTH-1:0] s2_im [0:7];
    reg signed [OUT_WIDTH-1:0] s3_re [0:7];
    reg signed [OUT_WIDTH-1:0] s3_im [0:7];

    reg signed [OUT_WIDTH-1:0] t_re;
    reg signed [OUT_WIDTH-1:0] t_im;

    // Reverse a 3-bit index: 0,4,2,6,1,5,3,7.
    function [2:0] bit_reverse3;
        input [2:0] index;
        begin
            bit_reverse3 = {index[0], index[1], index[2]};
        end
    endfunction

    // Multiply by 0.7071 using Q14 fixed-point arithmetic.
    function signed [OUT_WIDTH-1:0] mul_707;
        input signed [OUT_WIDTH-1:0] value;
        reg signed [OUT_WIDTH+15:0] product;
        begin
            product = value * C707;
            mul_707 = product >>> 14;
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 1'b0;

            X0_re <= 0; X0_im <= 0;
            X1_re <= 0; X1_im <= 0;
            X2_re <= 0; X2_im <= 0;
            X3_re <= 0; X3_im <= 0;
            X4_re <= 0; X4_im <= 0;
            X5_re <= 0; X5_im <= 0;
            X6_re <= 0; X6_im <= 0;
            X7_re <= 0; X7_im <= 0;
        end else begin
            done <= 1'b0;

            case (state)
                IDLE: begin
                    if (start) begin
                        // Load the input in bit-reversed order.
                        for (i = 0; i < 8; i = i + 1) begin
                            d_re[bit_reverse3(i[2:0])] <= $signed(x_re[i*IN_WIDTH +: IN_WIDTH]);
                            d_im[bit_reverse3(i[2:0])] <= $signed(x_im[i*IN_WIDTH +: IN_WIDTH]);
                        end
                        state <= STAGE1;
                    end
                end

                STAGE1: begin
                    // Four 2-point butterflies.
                    for (i = 0; i < 8; i = i + 2) begin
                        s1_re[i]   <= d_re[i] + d_re[i+1];
                        s1_im[i]   <= d_im[i] + d_im[i+1];
                        s1_re[i+1] <= d_re[i] - d_re[i+1];
                        s1_im[i+1] <= d_im[i] - d_im[i+1];
                    end
                    state <= STAGE2;
                end

                STAGE2: begin
                    // Two 4-point FFT groups.
                    for (i = 0; i < 8; i = i + 4) begin
                        // Twiddle W4^0 = 1.
                        s2_re[i]   <= s1_re[i] + s1_re[i+2];
                        s2_im[i]   <= s1_im[i] + s1_im[i+2];
                        s2_re[i+2] <= s1_re[i] - s1_re[i+2];
                        s2_im[i+2] <= s1_im[i] - s1_im[i+2];

                        // Twiddle W4^1 = -j.
                        s2_re[i+1] <= s1_re[i+1] + s1_im[i+3];
                        s2_im[i+1] <= s1_im[i+1] - s1_re[i+3];
                        s2_re[i+3] <= s1_re[i+1] - s1_im[i+3];
                        s2_im[i+3] <= s1_im[i+1] + s1_re[i+3];
                    end
                    state <= STAGE3;
                end

                STAGE3: begin
                    // k = 0, W8^0 = 1
                    s3_re[0] <= s2_re[0] + s2_re[4];
                    s3_im[0] <= s2_im[0] + s2_im[4];
                    s3_re[4] <= s2_re[0] - s2_re[4];
                    s3_im[4] <= s2_im[0] - s2_im[4];

                    // k = 1, W8^1 = 0.7071 - j0.7071
                    t_re = mul_707(s2_re[5] + s2_im[5]);
                    t_im = mul_707(s2_im[5] - s2_re[5]);
                    s3_re[1] <= s2_re[1] + t_re;
                    s3_im[1] <= s2_im[1] + t_im;
                    s3_re[5] <= s2_re[1] - t_re;
                    s3_im[5] <= s2_im[1] - t_im;

                    // k = 2, W8^2 = -j
                    s3_re[2] <= s2_re[2] + s2_im[6];
                    s3_im[2] <= s2_im[2] - s2_re[6];
                    s3_re[6] <= s2_re[2] - s2_im[6];
                    s3_im[6] <= s2_im[2] + s2_re[6];

                    // k = 3, W8^3 = -0.7071 - j0.7071
                    t_re = mul_707(s2_im[7] - s2_re[7]);
                    t_im = mul_707(-s2_re[7] - s2_im[7]);
                    s3_re[3] <= s2_re[3] + t_re;
                    s3_im[3] <= s2_im[3] + t_im;
                    s3_re[7] <= s2_re[3] - t_re;
                    s3_im[7] <= s2_im[3] - t_im;

                    state <= OUTPUT;
                end

                OUTPUT: begin
                    X0_re <= s3_re[0]; X0_im <= s3_im[0];
                    X1_re <= s3_re[1]; X1_im <= s3_im[1];
                    X2_re <= s3_re[2]; X2_im <= s3_im[2];
                    X3_re <= s3_re[3]; X3_im <= s3_im[3];
                    X4_re <= s3_re[4]; X4_im <= s3_im[4];
                    X5_re <= s3_re[5]; X5_im <= s3_im[5];
                    X6_re <= s3_re[6]; X6_im <= s3_im[6];
                    X7_re <= s3_re[7]; X7_im <= s3_im[7];
                    done <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
