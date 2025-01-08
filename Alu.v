module alu (
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] aluControl,
    output reg zero,
    output reg [31:0] aluResult
);

    // Internal wires for add/sub results
    wire [31:0] addResult, subResult;
    wire cout_add, cout_sub;

    // Internal registers for multiplication and division
    reg [63:0] product;
    reg [31:0] quotient, remainder;
    reg signed [31:0] signed_srcA, signed_srcB;
    reg [31:0] unsigned_srcA, unsigned_srcB;
    reg signed [31:0] dividend_signed, divisor_signed;
    reg [31:0] dividend_unsigned, divisor_unsigned;
    integer i;

    // Instantiating adders and subtractors
    full_adder_32bit adder (
        .a(srcA),
        .b(srcB),
        .cin(1'b0),
        .sum(addResult),
        .cout(cout_add)
    );

    full_adder_32bit subtractor (
        .a(srcA),
        .b(~srcB + 1), // Two's complement for subtraction
        .cin(1'b0),
        .sum(subResult),
        .cout(cout_sub)
    );

    always @(*) begin
        // Default assignments
        aluResult = 32'b0;
        zero = 1'b0;

        case (aluControl)
            4'b0000: aluResult = addResult; // ADD
            4'b0001: aluResult = subResult; // SUB
            4'b0100: aluResult = srcA & srcB; // AND
            4'b0101: aluResult = srcA | srcB; // OR
            4'b0010: aluResult = bitwise_shift_left(srcA, srcB[4:0]); // Shift srcA by srcB[4:0]  SLL
            4'b0011: aluResult = ($signed(srcA) < $signed(srcB)) ? 32'b1 : 32'b0; // SLT
            4'b1111: aluResult = (srcA < srcB) ? 32'b1 : 32'b0; // SLTU
            
            4'b0110: aluResult = srcA ^ srcB; // XOR
            4'b0111: aluResult = bitwise_shift_right_logical(srcA, srcB[4:0]);  // SRL (Shift Right Logical)
            4'b1000: aluResult = bitwise_shift_right_arithmetic(srcA, srcB[4:0]); // SRA (Shift Right Arithmetic)

            // Multiplication Instructions
            4'b0111: begin // MUL (Signed x Signed)
                product = 64'b0;
                signed_srcA = srcA;
                signed_srcB = srcB;

                for (i = 0; i < 32; i = i + 1) begin
                    if (signed_srcB[i]) begin
                        product = bitwise_add(product, $signed({32'b0, signed_srcA}) << i);
                    end
                end

                aluResult = product[31:0]; // Low 32 bits
            end

            4'b1000: begin // MULH (Signed x Signed High 32 bits)
                product = 64'b0;
                signed_srcA = srcA;
                signed_srcB = srcB;

                for (i = 0; i < 32; i = i + 1) begin
                    if (signed_srcB[i]) begin
                        product = bitwise_add(product, $signed({32'b0, signed_srcA}) << i);
                    end
                end

                aluResult = product[63:32]; // High 32 bits
            end

            4'b1001: begin // MULHU (Unsigned x Unsigned High 32 bits)
                product = 64'b0;
                unsigned_srcA = srcA;
                unsigned_srcB = srcB;

                for (i = 0; i < 32; i = i + 1) begin
                    if (unsigned_srcB[i]) begin
                        product = bitwise_add(product, {32'b0, unsigned_srcA} << i);
                    end
                end

                aluResult = product[63:32]; // High 32 bits
            end

            4'b1010: begin // MULHSU (Signed x Unsigned High 32 bits)
                product = 64'b0;
                signed_srcA = srcA;
                unsigned_srcB = srcB;

                for (i = 0; i < 32; i = i + 1) begin
                    if (unsigned_srcB[i]) begin
                        product = bitwise_add(product, $signed({32'b0, signed_srcA}) << i);
                    end
                end

                aluResult = product[63:32]; // High 32 bits
            end

            // Division Instructions
            4'b1011: begin // DIV (Signed Division)
                dividend_signed = srcA;
                divisor_signed = srcB;

                quotient = 32'b0;
                remainder = 32'b0;

                for (i = 31; i >= 0; i = i - 1) begin
                    remainder = bitwise_shift_left_div(remainder, dividend_signed[31 - i]);
                    if (remainder >= divisor_signed) begin
                        remainder = bitwise_sub(remainder, divisor_signed);
                        quotient[i] = 1;
                    end
                end

                aluResult = quotient;
            end

            4'b1100: begin // DIVU (Unsigned Division)
                dividend_unsigned = srcA;
                divisor_unsigned = srcB;

                quotient = 32'b0;
                remainder = 32'b0;

                for (i = 31; i >= 0; i = i - 1) begin
                    remainder = bitwise_shift_left_div(remainder, dividend_unsigned[31 - i]);
                    if (remainder >= divisor_unsigned) begin
                        remainder = bitwise_sub(remainder, divisor_unsigned);
                        quotient[i] = 1;
                    end
                end

                aluResult = quotient;
            end

            4'b1101: begin // REM (Signed Remainder)
                dividend_signed = srcA;
                divisor_signed = srcB;

                quotient = 32'b0;
                remainder = 32'b0;

                for (i = 31; i >= 0; i = i - 1) begin
                    remainder = bitwise_shift_left_div(remainder, dividend_signed[31 - i]);
                    if (remainder >= divisor_signed) begin
                        remainder = bitwise_sub(remainder, divisor_signed);
                        quotient[i] = 1;
                    end
                end

                aluResult = remainder;
            end

            4'b1110: begin // REMU (Unsigned Remainder)
                dividend_unsigned = srcA;
                divisor_unsigned = srcB;

                quotient = 32'b0;
                remainder = 32'b0;

                for (i = 31; i >= 0; i = i - 1) begin
                    remainder = bitwise_shift_left_div(remainder, dividend_unsigned[31 - i]);
                    if (remainder >= divisor_unsigned) begin
                        remainder = bitwise_sub(remainder, divisor_unsigned);
                        quotient[i] = 1;
                    end
                end

                aluResult = remainder;
            end

            default: aluResult = 32'b0; // Default case
        endcase

        // Zero flag
        zero = (aluResult == 32'b0) ? 1'b1 : 1'b0;
    end
    
    // Helper functions for bitwise operations
    function [31:0] bitwise_add(input [31:0] a, b);
    
    reg [31:0] sum;    // Sum result
    reg carry;         // Carry bit
    integer i;         // Loop index

    begin
        carry = 1'b0; // Initialize carry to 0
        for (i = 0; i < 32; i = i + 1) begin
            // XOR for sum, AND/OR for carry
            sum[i] = a[i] ^ b[i] ^ carry; // Sum for this bit
            carry = (a[i] & b[i]) | (carry & (a[i] ^ b[i])); // Propagate carry
        end
        bitwise_add = sum; // Return the computed sum
    end
    endfunction

    function [31:0] bitwise_sub(input [31:0] a, b);
    
        reg [31:0] inverted_b; // Inverted `b`
        begin
            inverted_b = ~b; // Bitwise NOT of `b`
            bitwise_sub = bitwise_add(a, bitwise_add(inverted_b, 32'b1)); // a + (~b + 1)
        end
    endfunction


    function [31:0] bitwise_shift_left_div;     // appending a single bit (specific for reestoring division algo)
    input [31:0] a;  // Operand to shift
    input b;         // Single bit to append (0 or 1)
    begin
        bitwise_shift_left_div = {a[30:0], b}; // Shift left by 1 bit and append `b`
    end
    endfunction

    function [31:0] bitwise_shift_left;
    input [31:0] a;  // Operand to shift
    input [4:0] b;   // Shift amount (only lower 5 bits are used)
    reg [31:0] result; 
    integer i;         

    begin
        result = a; // Initialize result with `a`
        for (i = 0; i < b; i = i + 1) begin
            result = {result[30:0], 1'b0}; // Shift left by 1 bit
        end
        bitwise_shift_left = result; // Return the shifted result
    end
endfunction
function [31:0] bitwise_shift_right_logical;
    input [31:0] a;  // Operand to shift
    input [4:0] b;   // Shift amount 5 bits (0-31)
    reg [31:0] result; 
    integer i;

    begin
        result = a; // Initialize result with `a`
        for (i = 0; i < b; i = i + 1) begin
            result = {1'b0, result[31:1]}; // Shift right by 1 bit, fill MSB with 0
        end
        bitwise_shift_right_logical = result; // Return the shifted result
    end
endfunction
function [31:0] bitwise_shift_right_arithmetic;
    input [31:0] a;  // Operand to shift
    input [4:0] b;   // Shift amount 5 bits (0-31) 
    reg [31:0] result; 
    integer i;

    begin
        result = a; // Initialize result with `a`
        for (i = 0; i < b; i = i + 1) begin
            result = {result[31], result[31:1]}; // Shift right by 1 bit, fill MSB with sign bit
        end
        bitwise_shift_right_arithmetic = result; // Return the shifted result
    end
endfunction

    
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
