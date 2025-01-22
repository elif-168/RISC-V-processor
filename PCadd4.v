
`include "FullAdder.v"


module PC_add4 (
    input [31:0] pc,      // current pc value
    output [31:0] next_pc  // updated pc value
);

    wire [31:0] plus4;   // value to increment pc by 
    wire carry_out;          // carry out for fulladder

    assign plus4 = 32'd4; // 

    // PC + 4 with fulladder
      full_adder_32bit adder (
        .a(pc),
        .b(plus4),
        .cin(1'b0),
        .sum(next_pc),
        .cout(carry_out)
    );

endmodule

