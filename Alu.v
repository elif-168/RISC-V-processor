`include "FullAdder.v"

module alu (
    input [31:0] srcA,
    input [31:0] srcB,
    input [5:0] aluControl,
    output reg zero,
    output reg [31:0] aluResult,
    output reg branch_taken
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
    reg [31:0] temp;

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
        branch_taken = 1'b0;
        case (aluControl)
            6'b000000: aluResult = addResult; // ADD
            6'b000001: aluResult = subResult; // SUB
            6'b000010: aluResult = srcA & srcB; // AND
            6'b000011: aluResult = srcA | srcB; // OR
            6'b000100: aluResult = srcA ^ srcB; // XOR
            6'b000101: aluResult = ($signed(srcA) < $signed(srcB)) ? 32'b1 : 32'b0; // SLT
            6'b000110: aluResult = bitwise_shift_left(srcA, srcB[4:0]); // Shift srcA by srcB[4:0]  SLL
            
            6'b000111: aluResult = (srcA < srcB) ? 32'b1 : 32'b0; // SLTU
            
            6'b001000: aluResult = bitwise_shift_right_logical(srcA, srcB[4:0]);  // SRL (Shift Right Logical)
            6'b001001: aluResult = bitwise_shift_right_arithmetic(srcA, srcB[4:0]); // SRA (Shift Right Arithmetic)

            6'b001010: aluResult = srcA & ~srcB; // ANDN
            6'b001011: aluResult = srcA | ~srcB; // ORN
            6'b001100: aluResult = srcA ^ ~srcB; // XNOR
            6'b001101: aluResult = {srcA[7:0], srcA[15:8], srcA[23:16], srcA[31:24]}; // REV8(Reverse Byte Order)
            6'b001110: aluResult = (srcA << srcB[4:0]) | (srcA >> (32 - srcB[4:0])); // ROL
            6'b001111: aluResult = (srcA >> srcB[4:0]) | (srcA << (32 - srcB[4:0])); // ROR


             //B-extension instructions
 
            6'b010010: aluResult = (srcA << 1) + srcB; // SH1ADD (Shift Left 1 and Add)
            6'b010011: aluResult = (srcA << 2) + srcB; // SH2ADD (Shift Left 2 and Add)
            6'b010100: aluResult = (srcA << 3) + srcB; // SH3ADD (Shift Left 3 and Add)  
            // Bit manipulation
            6'b010101: aluResult = srcA ^ (1 << srcB[4:0]); // BINV (Bit Invert)
            6'b010110: aluResult = srcA & ~(1 << srcB[4:0]); // BCLR (Bit Clear)
            6'b010111: aluResult = srcA | (1 << srcB[4:0]); // BSET (Bit Set) shifts 1 by the number in src[4:0]

            // Min and Max
            6'b011000: aluResult = ($signed(srcA) > $signed(srcB)) ? srcA : srcB; // MAX
            6'b011001: aluResult = ($signed(srcA) < $signed(srcB)) ? srcA : srcB; // MIN
            6'b011010: aluResult = (srcA > srcB) ? srcA : srcB; // MAXU (Unsigned)
            6'b011011: aluResult = (srcA < srcB) ? srcA : srcB; // MINU (Unsigned)

                   

            6'b011100: aluResult = {  //ORC.B
                (|srcA[31:24] ? 8'hFF : 8'h00), // Check the most significant byte
                (|srcA[23:16] ? 8'hFF : 8'h00), // Check the second byte
                (|srcA[15:8]  ? 8'hFF : 8'h00), // Check the third byte
                (|srcA[7:0]   ? 8'hFF : 8'h00)  // Check the least significant byte
            };

            // Sign and Zero Extension
            6'b011101: aluResult = {{24{srcA[7]}}, srcA[7:0]}; // SEXT.B (Sign Extend Byte)
            6'b011110: aluResult = {{16{srcA[15]}}, srcA[15:0]}; // SEXT.H (Sign Extend Halfword)
            6'b011111: aluResult = {16'b0, srcA[15:0]}; // ZEXT.H (Zero Extend Halfword)

            // Population count
            6'b100000: begin
                temp = srcA;
                aluResult = 0;
                for (i = 0; i < 32; i = i + 1)
                    aluResult = aluResult + temp[i];
            end // CPOP

            // trailing zero count  CTZ
            6'b100001: begin
                aluResult = 0;
                temp = srcA;
                while (temp[31] == 0 && aluResult < 32) begin
                    aluResult = aluResult + 1;
                    temp = temp << 1;
                end
            end // Leading zero count CLZ
            6'b100010: begin
                aluResult = 0;
                temp = srcA;
                while (temp[0] == 0 && aluResult < 32) begin
                    aluResult = aluResult + 1;
                    temp = temp >> 1;
                end
            end // CTZ

            6'b100011: aluResult = ($signed(srcA) > $signed(srcB)) ? srcA : srcB; // MAX
            6'b100100: aluResult = ($signed(srcA) < $signed(srcB)) ? srcA : srcB; // MIN
            6'b100101: aluResult = (srcA > srcB) ? srcA : srcB; // MAXU
            6'b100110: aluResult = (srcA < srcB) ? srcA : srcB; // MINU

            // Multiplication Instructions
            6'b100111: begin // MUL (Signed x Signed)
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

            6'b101000: begin // MULH (Signed x Signed High 32 bits)
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

            6'b101001: begin // MULHU (Unsigned x Unsigned High 32 bits)
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

            6'b101010: begin // MULHSU (Signed x Unsigned High 32 bits)
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
            6'b101011: begin // DIV (Signed Division)
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

            6'b101100: begin // DIVU (Unsigned Division)
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

            6'b101101: begin // REM (Signed Remainder)
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

            6'b101110: begin // REMU (Unsigned Remainder)
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
            6'b101111: branch_taken = (srcA == srcB); // BEQ
            6'b110000: branch_taken = (srcA != srcB); // BNE
            6'b110001: branch_taken = ($signed(srcA) < $signed(srcB)); // BLT (Signed)
            6'b110010: branch_taken = (srcA < srcB); // BLTU (Unsigned)
            6'b110011: branch_taken = ($signed(srcA) >= $signed(srcB)); // BGE (Signed)
            6'b110100: branch_taken = (srcA >= srcB); // BGEU (Unsigned)
            6'b110101: branch_taken = 1; //JAL 
            6'b110110: begin
                branch_taken = 1; //JALR
                aluResult = addResult; // ADD
            end

            default: begin
                aluResult = 32'b0; // Default case /NOP /FENCE
                branch_taken = 0;
            end
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

