`include "ControlUnit.v"

module control_unit_tb;

    reg [6:0] op;
    reg [2:0] funct3;
    reg [2:0]funct7; // funct7 is 1 bit as it is sufficient to distinguish certain instructions
    reg zero;

    wire pcSrc;
    wire resultSrc;
    wire memWrite;
    wire [5:0] aluControl;
    wire aluSrc;
    wire [2:0] immSrc;
    wire regWrite;

    control_unit dut (
        .op(op),
        .funct3(funct3),
        .funct7(funct7),
        .zero(zero),

        .pcSrc(pcSrc),
        .resultSrc(resultSrc),
        .aluControl(aluControl),
        .aluSrc(aluSrc),
        .immSrc(immSrc),
        .regWrite(regWrite)
    );

     initial begin
        $dumpfile("ControlUnit_tb.vcd");
         $dumpvars(0, control_unit_tb);

        // Test R-Type instruction (ADD)
        op = 7'b0110011; // R-Type opcode
        funct3 = 3'b000;
        funct7 = 0;
        zero = 0;
        #10;  
        $display("R-Type:  pcSrc= %b,  resultSrc = %b, memWrite = %b, aluControl = %b, aluSrc = %b, immSrc = %b, regWrite = %b", pcSrc, resultSrc, memWrite, aluControl, aluSrc, immSrc, regWrite);

        // Test I-Type instruction (LOAD)
        op = 7'b0000011; // I-LOAD opcode
        funct3 = 3'b000;
        funct7 = 0;
        zero = 0;
        #10;

        $display("I_LOAD:  pcSrc= %b,  resultSrc = %b, memWrite = %b, aluControl = %b, aluSrc = %b, immSrc = %b, regWrite = %b", pcSrc, resultSrc, memWrite, aluControl, aluSrc, immSrc, regWrite);

        // Test I-Type instruction (ADDI)
        op = 7'b0010011; // I-ALU opcode
        funct3 = 3'b000; // ADDI
        funct7 = 0;
        zero = 0;
        #10;
        $display("I_ADDI:  pcSrc= %b,  resultSrc = %b, memWrite = %b, aluControl = %b, aluSrc = %b, immSrc = %b, regWrite = %b", pcSrc, resultSrc, memWrite, aluControl, aluSrc, immSrc, regWrite);

        // Test S-Type instruction (STORE)
        op = 7'b0100011; // S-Type opcode
        funct3 = 3'b010;
        funct7 = 0;
        zero = 0;
        #10;

        $display("S_Store:  pcSrc= %b,  resultSrc = %b, memWrite = %b, aluControl = %b, aluSrc = %b, immSrc = %b, regWrite = %b", pcSrc, resultSrc, memWrite, aluControl, aluSrc, immSrc, regWrite);

        // Test B-Type instruction (BEQ)
        op = 7'b1100011; // B-Type opcode
        funct3 = 3'b000; // BEQ
        funct7 = 0;
        zero = 1; // Branch taken
        #10;

        $display("B_BEQ:  pcSrc= %b,  resultSrc = %b, memWrite = %b, aluControl = %b, aluSrc = %b, immSrc = %b, regWrite = %b", pcSrc, resultSrc, memWrite, aluControl, aluSrc, immSrc, regWrite);

        // Test J-Type instruction (JAL)
        op = 7'b1101111; // J-Type opcode
        funct3 = 3'b000;
        funct7 = 0;
        zero = 0;
        #10;

        $display("J_JAL:  pcSrc= %b,  resultSrc = %b, memWrite = %b, aluControl = %b, aluSrc = %b, immSrc = %b, regWrite = %b", pcSrc, resultSrc, memWrite, aluControl, aluSrc, immSrc, regWrite);

        // Test U-Type instruction (LUI)
        op = 7'b0110111; // U-LUI opcode
        funct3 = 3'b000;
        funct7 = 0;
        zero = 0;
        #10;

        $display("U_LUI:  pcSrc= %b,  resultSrc = %b, memWrite = %b, aluControl = %b, aluSrc = %b, immSrc = %b, regWrite = %b", pcSrc, resultSrc, memWrite, aluControl, aluSrc, immSrc, regWrite);

        // Test I-Type (FENCE)
        op = 7'b0001111; // I-FENCE opcode
        funct3 = 3'b000;
        funct7 = 0;
        zero = 0;
        #10;
        $display("I_FENCE:  pcSrc= %b,  resultSrc = %b, memWrite = %b, aluControl = %b, aluSrc = %b, immSrc = %b, regWrite = %b", pcSrc, resultSrc, memWrite, aluControl, aluSrc, immSrc, regWrite);

        // Test I-Type (ECALL)
        op = 7'b1110011; // I-ECALL opcode
        funct3 = 3'b000;
        funct7 = 0;
        zero = 0;
        #10;

        $display("I_ECALL:  pcSrc= %b,  resultSrc = %b, memWrite = %b, aluControl = %b, aluSrc = %b, immSrc = %b, regWrite = %b branch = %b", pcSrc, resultSrc, memWrite, aluControl, aluSrc, immSrc, regWrite);

        $finish;
    end



endmodule



//iverilog -o ControlUnit_tb.vvp ControlUnit_tb.v
//vvp ControlUnit_tb.vvp
