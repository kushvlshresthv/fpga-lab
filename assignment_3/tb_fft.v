`timescale 1ns/1ps

module tb_fft;
    parameter IN_WIDTH  = 16;
    parameter OUT_WIDTH = 24;

    reg clk;
    reg rst;
    reg start;

    reg signed [8*IN_WIDTH-1:0] x_re;
    reg signed [8*IN_WIDTH-1:0] x_im;

    wire done;
    wire signed [OUT_WIDTH-1:0] X0_re, X0_im;
    wire signed [OUT_WIDTH-1:0] X1_re, X1_im;
    wire signed [OUT_WIDTH-1:0] X2_re, X2_im;
    wire signed [OUT_WIDTH-1:0] X3_re, X3_im;
    wire signed [OUT_WIDTH-1:0] X4_re, X4_im;
    wire signed [OUT_WIDTH-1:0] X5_re, X5_im;
    wire signed [OUT_WIDTH-1:0] X6_re, X6_im;
    wire signed [OUT_WIDTH-1:0] X7_re, X7_im;

    integer errors;

    fft_8point #(
        .IN_WIDTH(IN_WIDTH),
        .OUT_WIDTH(OUT_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .x_re(x_re),
        .x_im(x_im),
        .done(done),
        .X0_re(X0_re), .X0_im(X0_im),
        .X1_re(X1_re), .X1_im(X1_im),
        .X2_re(X2_re), .X2_im(X2_im),
        .X3_re(X3_re), .X3_im(X3_im),
        .X4_re(X4_re), .X4_im(X4_im),
        .X5_re(X5_re), .X5_im(X5_im),
        .X6_re(X6_re), .X6_im(X6_im),
        .X7_re(X7_re), .X7_im(X7_im)
    );

    always #5 clk = ~clk;

    task check_value;
        input integer index;
        input signed [OUT_WIDTH-1:0] got_re;
        input signed [OUT_WIDTH-1:0] got_im;
        input integer exp_re;
        input integer exp_im;
        begin
            if (($signed(got_re) !== exp_re) || ($signed(got_im) !== exp_im)) begin
                $display("FAIL X[%0d]: got %0d + j(%0d), expected %0d + j(%0d)",
                         index, $signed(got_re), $signed(got_im), exp_re, exp_im);
                errors = errors + 1;
            end else begin
                $display("PASS X[%0d]: %0d + j(%0d)",
                         index, $signed(got_re), $signed(got_im));
            end
        end
    endtask

    initial begin
        $dumpfile("fft.vcd");
        $dumpvars(0, tb_fft);

        clk = 0;
        rst = 1;
        start = 0;
        x_re = 0;
        x_im = 0;
        errors = 0;

        #20;
        rst = 0;
        #10;

        // Test input: x[n] = 1,2,3,4,5,6,7,8 with zero imaginary part.
        x_re[0*IN_WIDTH +: IN_WIDTH] = 16'sd1;
        x_re[1*IN_WIDTH +: IN_WIDTH] = 16'sd2;
        x_re[2*IN_WIDTH +: IN_WIDTH] = 16'sd3;
        x_re[3*IN_WIDTH +: IN_WIDTH] = 16'sd4;
        x_re[4*IN_WIDTH +: IN_WIDTH] = 16'sd5;
        x_re[5*IN_WIDTH +: IN_WIDTH] = 16'sd6;
        x_re[6*IN_WIDTH +: IN_WIDTH] = 16'sd7;
        x_re[7*IN_WIDTH +: IN_WIDTH] = 16'sd8;
        x_im = 0;

        start = 1;
        #10;
        start = 0;

        @(posedge done);
        #1;

        $display("\n8-point FFT result:");
        check_value(0, X0_re, X0_im,  36,  0);
        check_value(1, X1_re, X1_im,  -4,  9);
        check_value(2, X2_re, X2_im,  -4,  4);
        check_value(3, X3_re, X3_im,  -4,  1);
        check_value(4, X4_re, X4_im,  -4,  0);
        check_value(5, X5_re, X5_im,  -4, -1);
        check_value(6, X6_re, X6_im,  -4, -4);
        check_value(7, X7_re, X7_im,  -4, -9);

        if (errors == 0)
            $display("\nVERIFICATION PASSED");
        else
            $display("\nVERIFICATION FAILED: %0d error(s)", errors);

        #20;
        $finish;
    end

endmodule
