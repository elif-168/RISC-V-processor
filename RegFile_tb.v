`include "RegFile.v"

module reg_file_tb;

reg clk;
reg we;
reg [4:0] readA1, readA2, writeA3;
reg [31:0] data;

wire [31:0] RD1, RD2;

reg_file dut (
    .clk(clk),
    .we(we),
    .readA1(readA1),
    .readA2(readA2),
    .writeA3(writeA3),
    .data(data),
    .RD1(RD1),
    .RD2(RD2)
);

 always #5 clk = ~clk;

 initial begin
    $dumpfile("RegFile.vcd");
   $dumpvars(0,reg_file_tb); 

        clk = 0;

        we = 0;
        readA1 = 0;
        readA2 = 0;
        writeA3 = 0;
        data = 0;

        // Read from register 0 
        #10;
        $display("register 0: RD1 = %h, RD2 = %h", RD1, RD2);

        // Write to register 1
        we = 1;
        writeA3 = 5'd1;
        data = 32'hEEADB00C;
        #10;
        we = 0;

        //Read from register 1
        readA1 = 5'd1;
        #10;
        $display("Time %0t: Read from register 1: RD1 = %h", $time, RD1);

        // Write to register 2 and read from register 2
        we = 1;
        writeA3 = 5'd2;
        data = 32'h56AB9900;
        #10;
        we = 0;
        readA2 = 5'd2;
        #10;
        $display("Time %0t: Read from register 2: RD2 = %h", $time, RD2);

        // Test register 0 remains hardwired to 0 even after writing
        we = 1;
        writeA3 = 5'd0;
        data = 32'hFFFFFFFF;
        #10;
        we = 0;
        readA1 = 5'd0;
        #10;
        $display("Time %0t: Register 0 remains: RD1 = %h", $time, RD1);

        $finish;
 end

    
endmodule

//iverilog -o RegFile_tb.vvp RegFile_tb.v
//vvp RegFile_tb.vvp