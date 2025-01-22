`include "processor.v"

module processor_tb;

    // Testbench Signals
    reg clk;
    reg reset;

    // Instantiate the processor
    processor dut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Test stimulus
    initial begin
        // Initialize reset
        reset = 1;
        #10; // Wait for 10ns

        // Release reset
        reset = 0;

        // Run simulation for a specific time
        #3000;

        // Finish simulation
        $finish;
    end

    // Monitor signals for debugging
    initial begin
        $monitor("Time: %0t | PC: %h | Instruction: %h | ALU Result: %h | Data Mem Output: %h | WB Data: %h | branch_taken: %h",
                 $time, dut.pc_current, dut.instruction, dut.aluResult, dut.readData, dut.result, dut.branch_taken);
        $monitor("Time: %0t | PC: %h | Instruction: %h | PCSrc: %b | Branch Taken: %b | ALU Zero: %b | PC Target: %h | PC Next: %h | aluResult %h | aluControl: %h| extended imm : %h| mux_out_pc: %h| imm_src: %h | alusrcB: %h| controlunit: resultSrc: %b| funct3: %h | funct7: %h",
          $time, dut.pc_current, dut.instruction, dut.pcSrc, dut.branch_taken, dut.aluZero, dut.pc_target, dut.pc_next, dut.aluResult, dut.aluControl, dut.imm_extended, dut.pc_mux_out, dut.immSrc, dut.alu_srcB, dut.resultSrc, dut.instruction[14:12], dut.instruction[31:29]);
    
    end

    // Dump signals for waveform viewing
    initial begin
        $dumpfile("processor_tb.vcd");
        $dumpvars(0, processor_tb);
    end

endmodule


//iverilog -o processor_tb.vvp processor_tb.v
//vvp processor_tb.vvp 
//gtkWave processor_tb.vcd

