// In dataflow style, we don't use "always" blocks, we use "assign statements"
// and verilog keeps re-evaluating these assigns wheneer any input changes

module alu8_dataflow (
    input  wire [7:0] A,
    input  wire [7:0] B,
    input  wire [3:0] sel,     // chooses which operation to do
    output wire [7:0] Result,  // final output
    output wire        Cout,    // carry out (only meaningful for add/sub)
    output wire        Zero,    // 1 if Result is all zeros
    output wire        Overflow // signed overflow flag (add/sub only)
);

    // we compute everything in parallel wires,
    // and later just "pick" the one we want with a mux.

    wire [8:0] add_full = {1'b0, A} + {1'b0, B}; // 9 bits to catch carry
    wire [8:0] sub_full = {1'b0, A} - {1'b0, B}; // 9 bits to catch borrow

    wire [7:0] add_res = add_full[7:0];
    wire [7:0] sub_res = sub_full[7:0];

    wire [7:0] and_res  = A & B;
    wire [7:0] or_res   = A | B;
    wire [7:0] xor_res  = A ^ B;
    wire [7:0] nor_res  = ~(A | B);
    wire [7:0] nand_res = ~(A & B);
    wire [7:0] xnor_res = ~(A ^ B);
    wire [7:0] not_res  = ~A;

    wire [7:0] shl_res  = A << 1;          // shift left by 1
    wire [7:0] shr_res  = A >> 1;          // shift right by 1

    wire [7:0] rol_res  = {A[6:0], A[7]};  // rotate left
    wire [7:0] ror_res  = {A[0], A[7:1]};  // rotate right

    wire [7:0] mul_res  = A * B;           // only keep lower 8 bits

    wire [7:0] gt_res   = {7'b0, (A > B)};  // 1 if A greater than B
    wire [7:0] eq_res   = {7'b0, (A == B)}; // 1 if A equal to B

    //pick one operation based on the `sel`

    assign Result =
        (sel == 4'b0000) ? add_res  :  // ADD
        (sel == 4'b0001) ? sub_res  :  // SUBTRACT
        (sel == 4'b0010) ? and_res  :  // AND
        (sel == 4'b0011) ? or_res   :  // OR
        (sel == 4'b0100) ? xor_res  :  // XOR
        (sel == 4'b0101) ? nor_res  :  // NOR
        (sel == 4'b0110) ? nand_res :  // NAND
        (sel == 4'b0111) ? xnor_res :  // XNOR
        (sel == 4'b1000) ? not_res  :  // NOT
        (sel == 4'b1001) ? shl_res  :  // SHIFT LEFT
        (sel == 4'b1010) ? shr_res  :  // SHIFT RIGHT
        (sel == 4'b1011) ? rol_res  :  // ROTATE LEFT
        (sel == 4'b1100) ? ror_res  :  // ROTATE RIGHT
        (sel == 4'b1101) ? mul_res  :  // MULTIPLY
        (sel == 4'b1110) ? gt_res   :  // GREATER THAN
        (sel == 4'b1111) ? eq_res   :  // EQUAL TO
        8'b0;                          // default (just in case)

    // Only ADD and SUB actually produce a real carry/borrow.
    // For everything else, we just say Cout = 0.
    assign Cout =
        (sel == 4'b0000) ? add_full[8] :  // carry from add
        (sel == 4'b0001) ? sub_full[8] :  // borrow from sub
        1'b0;


    // ADD overflows when both inputs have the SAME sign
    // but the result has a DIFFERENT sign.
    // SUB overflows when inputs have DIFFERENT signs
    // but result's sign doesn't match A's sign.
    assign Overflow =
        (sel == 4'b0000) ? ((A[7] == B[7]) && (add_res[7] != A[7])) :
        (sel == 4'b0001) ? ((A[7] != B[7]) && (sub_res[7] != A[7])) :
        1'b0;

    //Zero flag - just check if Result is all 0s.
    assign Zero = (Result == 8'b0);

endmodule
