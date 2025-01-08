`include "PCadd4.v" // Include the module file

module PC_add4_tb;

    // Declare signals
    reg [31:0] pc_in;      // Use `reg` for input signals
    wire [31:0] pc_out;    // Use `wire` for output signals

    // Instantiate the Design Under Test (DUT)
    PC_add4 myDut (
        .pc(pc_in),        // Connect input signal to DUT
        .next_pc(pc_out)    // Connect output signal to DUT
    );

    // Testbench logic
    initial begin
        // Set up waveform dump for debugging
        $dumpfile("PCadd4_tb.vcd");
        $dumpvars(0, PC_add4_tb);

        // Test case 1: Initial value
        pc_in = 32'h00000000; // Set input
        #10; // Wait for 10 time units
        $display("Initial values: pc_in = %h, pc_out = %h", pc_in, pc_out);

        // Test case 2: Change input
        pc_in = 32'h00000001; // Update input
        #10; // Wait for 10 time units
        $display("Updated values: pc_in = %h, pc_out = %h", pc_in, pc_out);

        // End simulation
        $finish;
    end

endmodule
