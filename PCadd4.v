



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

