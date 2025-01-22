`include "InstructionMem.v"

module instruction_mem_tb;

    reg [31:0] address;       // Address input
    wire [31:0] instr;     // Instruction output

    // Instantiate the Instruction Memory module
    instruction_mem dut (
        .instruction_address(address),
        .instruction(instr)
    );

    initial begin
        $dumpfile("InstructionMem.vcd");
   $dumpvars(0,instruction_mem_tb); 
        // Test cases

        address = 0; #10; // Access instruction at address 0
        $display("Address: %h, Instruction: %b", address, instr);

        address = 1; #10; // Access instruction at address 1
        $display("Address: %h, Instruction: %b", address, instr);

        address = 16; #10; // Access instruction at address 2
        $display("Address: %h, Instruction: %b", address, instr);

        address = 17; #10; // Access instruction at address 3
        $display("Address: %h, Instruction: %b", address, instr);

        $finish; // End simulation
    end

endmodule
//iverilog -o InstructionMem_tb.vvp InstructionMem_tb.v
//vvp InstructionMem_tb.vvp