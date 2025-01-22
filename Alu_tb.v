`timescale 1ns / 1ps
`include "Alu.v"
module alu_tb;

    // Inputs to the ALU
    reg [31:0] srcA;
    reg [31:0] srcB;
    reg [5:0] aluControl;

    // Outputs from the ALU
    wire [31:0] aluResult;
    wire zero;

    // Instantiate the ALU module
    alu dut (
        .srcA(srcA),
        .srcB(srcB),
        .aluControl(aluControl),
        .aluResult(aluResult),
        .zero(zero)
    );

    // Test Procedure
    initial begin
        $dumpfile("Alu_tb.vcd");
        $dumpvars(0, alu_tb); 

        // Test ADD
        srcA = 32'h00000005; // 5
        srcB = 32'h00000003; // 3
        aluControl = 4'b0000; 
        #10;
        $display("ADD: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test SUB
        srcA = 32'h00000005; // 5
        srcB = 32'h00000005; // 5
        aluControl = 4'b0001; 
        #10;
        $display("SUB: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test AND
        srcA = 32'h0000000F; // 15
        srcB = 32'h000000F0; // 240
        aluControl = 4'b0100; 
        #10;
        $display("AND: srcA=%h, srcB=%h, aluResult=%h, zero=%b", srcA, srcB, aluResult, zero);

        // Test OR
        srcA = 32'h0000000F; // 15
        srcB = 32'h000000F0; // 240
        aluControl = 4'b0101; 
        #10;
        $display("OR: srcA=%h, srcB=%h, aluResult=%h, zero=%b", srcA, srcB, aluResult, zero);

        // Test XOR
        srcA = 32'h0000000F; // 15
        srcB = 32'h000000F0; // 240
        aluControl = 4'b0110; 
        #10;
        $display("XOR: srcA=%h, srcB=%h, aluResult=%h, zero=%b", srcA, srcB, aluResult, zero);

        // Test SLL
        srcA = 32'h00000001; // 1
        srcB = 32'h00000005; // 5 (Shift amount)
        aluControl = 4'b0010; 
        #10;
        $display("SLL: srcA=%h, srcB=%d, aluResult=%h, zero=%b", srcA, srcB[4:0], aluResult, zero);

        // Test SRL
        srcA = 32'h00000080; // 128
        srcB = 32'h00000004; // 4 (Shift amount)
        aluControl = 4'b0111; 
        #10;
        $display("SRL: srcA=%h, srcB=%d, aluResult=%h, zero=%b", srcA, srcB[4:0], aluResult, zero);

        // Test SRA
        srcA = 32'hFFFFFF80; // -128 in two's complement
        srcB = 32'h00000004; // 4 (Shift amount)
        aluControl = 4'b1000; 
        #10;
        $display("SRA: srcA=%h, srcB=%d, aluResult=%h, zero=%b", srcA, srcB[4:0], aluResult, zero);

        // Test SLT
        srcA = 32'h00000003; // 3
        srcB = 32'h00000005; // 5
        aluControl = 4'b0011; 
        #10;
        $display("SLT: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test SLTU
        srcA = 32'hFFFFFFFF; // Max unsigned value
        srcB = 32'h00000001; // 1
        aluControl = 4'b1111; 
        #10;
        $display("SLTU: srcA=%h, srcB=%h, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test Zero Flag
        srcA = 32'h00000000; // 0
        srcB = 32'h00000000; // 0
        aluControl = 4'b0000; // ADD
        #10;
        $display("Zero Flag Test: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

         // Test MUL
        srcA = 32'd10; // 10
        srcB = 32'd20; // 20
        aluControl = 4'b0111; 
        #10;
        $display("MUL: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test MULH
        srcA = 32'd100000; // Large positive number
        srcB = -32'd2;      // Negative number
        aluControl = 4'b1000; 
        #10;
        $display("MULH: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test MULHU
        srcA = 32'd300000; // Large positive number
        srcB = 32'd2000;   // Positive number
        aluControl = 4'b1001; 
        #10;
        $display("MULHU: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test MULHSU
        srcA = -32'd10; // Negative number
        srcB = 32'd3;   // Positive number
        aluControl = 4'b1010; 
        #10;
        $display("MULHSU: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test DIV
        srcA = 32'd100; // Dividend
        srcB = -32'd3;  // Divisor
        aluControl = 4'b1011; 
        #10;
        $display("DIV: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test DIVU
        srcA = 32'd100; // Dividend
        srcB = 32'd3;   // Divisor
        aluControl = 4'b1100; 
        #10;
        $display("DIVU: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test REM
        srcA = 32'd100; // Dividend
        srcB = -32'd3;  // Divisor
        aluControl = 4'b1101; 
        #10;
        $display("REM: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

        // Test REMU
        srcA = 32'd100; // Dividend
        srcB = 32'd3;   // Divisor
        aluControl = 4'b1110; 
        #10;
        $display("REMU: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);

            // Test BEQ: Branch if equal
        srcA = 32'd10;
        srcB = 32'd10;
        aluControl = 6'b101111; // BEQ
        #10;
        if (dut.branch_taken  !== 1) $display("Error: BEQ failed");

        // Test BNE: Branch if not equal
        srcA = 32'd10;
        srcB = 32'd5;
        aluControl = 6'b110000; // BNE
        #10;
        if (dut.branch_taken !== 1) $display("Error: BNE failed");

        srcA = 32'd10;
        srcB = 32'd5;
        aluControl = 6'b001110 ; // ROL
        #10;

        #10;
        $display("REMU: srcA=%d, srcB=%d, aluResult=%d, zero=%b", srcA, srcB, aluResult, zero);
           

        $finish;
    end
endmodule


//iverilog -o Alu_tb.vvp Alu_tb.v
//vvp Alu_tb.vvp