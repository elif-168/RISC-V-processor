`timescale 1ns / 1ps
`include "PcTargetAdder.v"

module PcTargetAdder_tb;

    // Inputs
    reg [31:0] pc;       // Current Program Counter
    reg [31:0] immVal;   // Immediate value

    // Output
    wire [31:0] pcTarget; // Target Program Counter

    // Instantiate the PCTargetAdder module
    PCTargetAdder uut (
        .pc(pc),
        .immVal(immVal),
        .pcTarget(pcTarget)
    );

    
    initial begin

         $dumpfile("PcTargetAdder_tb.vcd");
   $dumpvars(0,PcTargetAdder_tb);
    
        //values are coming from sign extend module so they are signed numbers

        // Test 1: 
        pc = 32'h00000010;
        immVal = 32'h00000004;
        #10;
        $display("Test 1: PC=%h, Immediate=%h, Target=%h", pc, immVal, pcTarget);

        // Test 2:  
        pc = 32'h00000100;
        immVal = 32'hFFFFFFFC;
        #10;
        $display("Test 2: PC=%h, Immediate=%h, Target=%h", pc, immVal, pcTarget);

        // Test 3: 
        pc = 32'h80000000;
        immVal = 32'h00001000;
        #10;
        $display("Test 3: PC=%h, Immediate=%h, Target=%h", pc, immVal, pcTarget);

        // Test  4: 
        pc = 32'h7FFFFFFF;
        immVal = 32'h00000001;
        #10;
        $display("Test 4: PC=%h, Immediate=%h, Target=%h", pc, immVal, pcTarget);

        // Test  5: 
        pc = 32'h00000000;
        immVal = 32'hFFFFFFFF;
        #10;
        $display("Test 5: PC=%h, Immediate=%h, Target=%h", pc, immVal, pcTarget);

        
        $finish;
    end

endmodule

//iverilog -o PcTargetAdder_tb.vvp PcTargetAdder_tb.v
//vvp PcTargetAdder_tb.vvp

