`include "ImmSignExtend.v"

module sign_extend_tb;

    reg [31:0] instruction;
    reg [2:0] inst_type;
    wire [31:0] out;

    // Instantiate the sign_extend module
    sign_extend dut (
        .instruction(instruction),
        .inst_type(inst_type),
        .out(out)
    );

    initial begin
        $dumpfile("ImmSignExtend_tb.vcd");
   $dumpvars(0, sign_extend_tb); 

        // B-Type
        instruction = 32'hFFF00013; 
        inst_type = 3'b000;
        #10 $display("B-Type: Immediate = %h", out);

        // I-Type 
        instruction = 32'h00408023; 
        inst_type = 3'b001;
        #10 $display("I-Type: Immediate = %h", out);

        // S-Type 
        instruction = 32'hFE0006E3; 
        inst_type = 3'b010;
        #10 $display("S-Type: Immediate = %h", out);

        //  U-Type 
        instruction = 32'h00001037; 
        inst_type = 3'b011;
        #10 $display("U-Type: Immediate = %h", out);

        //  J-Type 
        instruction = 32'h0040006F; 
        inst_type = 3'b100;
        #10 $display("J-Type: Immediate = %h", out);

        $finish;
    end

endmodule

//iverilog -o ImmsignExtend_tb.vvp ImmsignExtend_tb.v
//vvp ImmsignExtend_tb.vvp
