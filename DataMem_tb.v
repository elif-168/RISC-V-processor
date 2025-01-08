`timescale 1ns / 1ps
`include "DataMem.v"

module DataMemory_tb;
    reg clk;
    reg we;
    reg [31:0] wd;
    reg [31:0] addr;


    wire [31:0] dataOut;

    // Instantiate the DataMemory module
    DataMemory dut (
        .dataOut(dataOut),
        .clk(clk),
        .we(we),
        .wd(wd),
        .addr(addr)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock with period of 10ns
    end

    // Test Procedure
    initial begin
        // Initialize inputs
        we = 0;
        wd = 0;
        addr = 0;

        // Wait for memory initialization
        #10;

        // Test Read Operation (from initialized memory)
        addr = 32'h00000000; // Address 0
        #10;
        $display("Read from Address 0: Data=%h", dataOut);

        addr = 32'h00000001; // Address 1
        #10;
        $display("Read from Address 1: Data=%h", dataOut);

        // Test Write Operation
        we = 1;
        addr = 32'h00000002; // Address 2
        wd = 32'hCCDBEABF; // Write test data
        #10;

        we = 0; // Disable write
        addr = 32'h00000002; // Verify write at Address 2
        #10;
        $display("Read from Address 2 after write: Data=%h", dataOut);

        // Test Writing and Reading at Higher Addresses
        we = 1;
        addr = 32'h000000FF; // Address 255
        wd = 32'hCAFEBABE;
        #10;

        we = 0; // Disable write
        addr = 32'h000000FF; // Verify write at Address 255
        #10;
        $display("Read from Address 255 after write: Data=%h", dataOut);

        // End Test
        $finish;
    end

endmodule


//iverilog -o DataMem_tb.vvp DataMem_tb.v
//vvp DataMem_tb.vvp

