

`ifndef FULL_ADDER_32BIT
`define FULL_ADDER_32BIT

`include "FullAdder_bitwise.v"

module full_adder_32bit(
    input [31:0] a,         
    input [31:0] b,         
    input cin,              
    output [31:0] sum,      
    output cout             
);
    wire [31:0] carry;       

    genvar i;
    generate
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

    // The last carryout
    assign cout = carry[31];
endmodule

`endif



/*
`include "FullAdder_bitwise.v"

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

*/