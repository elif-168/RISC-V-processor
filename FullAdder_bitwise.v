
`ifndef FULL_ADDER
`define FULL_ADDER

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

`endif


/*
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
*/