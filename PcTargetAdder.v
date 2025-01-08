module PCTargetAdder
(
    input wire [31:0] pc,        // current program counter
    input wire [31:0] immVal, // extended immediate value 
    output wire [31:0] pcTarget  // Target program counter
);

    wire cout; // Carry-out of the addition

    // Instantiate the full adder to add PC and immediate
    full_adder_32bit adder (
        .a(pc),
        .b(immVal),
        .cin(1'b0),         // No initial carry-in
        .sum(pcTarget),   // Output sum (target PC)
        .cout(cout)         // Carry-out (not used here)
    );

endmodule

module full_adder_32bit(
    input [31:0] a,         
    input [31:0] b,          
    input cin,               
    output [31:0] sum,       
    output cout              
);
    wire [31:0] carry;       


    genvar i;
    generate //allows creating multiple instances in a block
        for (i = 0; i < 32; i = i + 1) begin : full_adder_gen
            if (i == 0) begin
                
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(cin),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end else begin
                
                full_adder fa (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carry[i-1]),
                    .sum(sum[i]),
                    .cout(carry[i])
                );
            end
        end
    endgenerate

    // the last carryout
    assign cout = carry[31];
endmodule

// bit size full adder
module full_adder(
    input a,                 
    input b,                 
    input cin,               
    output sum,              
    output cout              
);
    assign sum = a ^ b ^ cin; 
    assign cout = (a & b) | (b & cin) | (a & cin); 
endmodule
