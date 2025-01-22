`include "FullAdder.v"

module PCTargetAdder
(
    input wire [31:0] pc,        // current program counter
    input wire [31:0] immVal, // extended immediate value 
    output wire [31:0] pcTarget  // Target program counter
);

     wire signed [31:0] signed_pc;
    wire signed [31:0] signed_immVal;
    wire signed [31:0] signed_pcTarget;

    assign signed_pc = pc;
    assign signed_immVal = immVal;

    // Instantiate the full adder for signed addition
    full_adder_32bit adder (
        .a(signed_pc),
        .b(signed_immVal),
        .cin(1'b0),
        .sum(signed_pcTarget),
        .cout()
    );

    assign pcTarget = signed_pcTarget; // Return signed result 

/*
    wire signed [31:0] signed_pc;
    wire signed [31:0] signed_immVal;

    assign signed_pc = $signed(pc);
    assign signed_immVal = $signed(immVal);

    assign pcTarget = signed_pc + signed_immVal;
*/
    

endmodule
