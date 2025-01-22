`include "PC.v"
module Pc_tb;

    reg clk;
    reg reset;
    reg [31:0] pc_in;
    wire [31:0] pc_out;


    Pc dut (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );


    always #5 clk = ~clk;

    initial begin
        clk = 0;
        pc_in = 32'h00000000;
        
        // Display initial values
        $display("Initial values: pc_in = %h, pc_out = %h", pc_in, pc_out);
        
        #10; // Wait a bit

        $display("After some time: pc_in = %h, pc_out = %h", pc_in, pc_out);

        pc_in = 32'h00000001; 
        #10; // Wait a bit
        
        // Display updated values
        $display("Updated values: pc_in = %h, pc_out = %h", pc_in, pc_out);
        

        
        $finish; 
    end

    initial begin 
   $dumpfile("PC_tb.vcd");
   $dumpvars(0,Pc_tb); 

    end

endmodule

//iverilog -o pcounter_tb.vvp pcounter_tb.v
//vvp pcounter_tb.vvp
//

//iverilog -o pcounter_tb.vvp pcounter_tb.v
//vvp pcounter_tb.vvp
