`include "Alu.v"
`include "ControlUnit.v"
`include "DataMem.v"
`include "ImmSignExtend.v"
`include "InstructionMem.v"
`include "PC.v"
`include "PCadd4.v"
`include "PCTargetAdder.v"
`include "RegFile.v"



module processor (
    input clk,
    input reset
);

    // Wires and registers
    wire [31:0] pc_current, pc_next, pc_plus4, pc_target, result, readData;
    wire [31:0] instruction;
    wire[2:0] immSrc;
    wire [31:0] imm_extended;
    wire [5:0] aluControl;
    wire [31:0] reg_data1, reg_data2, alu_srcB;

    wire [31:0] aluResult, wb_data;
    wire branch_taken;

    wire [31:0] pc_mux_out;
    // Control signals
    wire aluZero, pcSrc, resultSrc, aluSrc,  memWrite, regWrite, we;

    
    wire  mem_read, mem_to_reg, branch;

    // PC Module
    Pc pc (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_next),
        .pc_out(pc_current)
    );

    // Instruction Memory
    instruction_mem imem (
        .instruction_address(pc_current),
        .instruction(instruction)
    );

    // PC+4 Adder
    PC_add4 pc_add4 (
        .pc(pc_current),
        .next_pc(pc_plus4)
    );

    // Immediate Sign Extend
    sign_extend imm_ext (
        .instruction(instruction),
        .inst_type(immSrc),
        .out(imm_extended)
    );
  

    // Control Unit
    control_unit control (
        .op(instruction[6:0]),
        .funct3(instruction[14:12]),
        .funct7(instruction[31:29]),
        .zero(aluZero),
        .pcSrc(pcSrc),
        .resultSrc(resultSrc),
        .memWrite(memWrite),
        .aluControl(aluControl),
        .aluSrc(aluSrc),
        .immSrc(immSrc),
        .regWrite(regWrite),
        .branch_taken(branch_taken)
    );

    // Register File
    reg_file regfile (
        .clk(clk),
        .readA1(instruction[19:15]),
        .readA2(instruction[24:20]),
        .writeA3(instruction[11:7]),
        .we(regWrite),
        .data(result),
        .RD1(reg_data1),
        .RD2(reg_data2)
    );

    // ALU Source Multiplexer
    assign alu_srcB = (aluSrc) ? imm_extended : reg_data2;

    // ALU
    alu alu (
        .srcA(reg_data1),
        .srcB(alu_srcB),
        .aluControl(aluControl),
        .aluResult(aluResult),
        .branch_taken(branch_taken),
        .zero(aluZero)
    );

    // Data Memory
    DataMemory dmem (
        .clk(clk),
        .we(memWrite),
        .wd(reg_data2),
        .addr(aluResult),
        .funct3(instruction[14:12]),
        .dataOut(readData)
    );


     // PC Target Adder
    PCTargetAdder pc_target_adder (
        .pc(pc_current),
        .immVal(imm_extended),
        .pcTarget(pc_target)
    );

    // PC Multiplexer
    assign pc_mux_out = (pcSrc & branch_taken) ? pc_target : pc_plus4;
    assign pc_next = pc_mux_out;
    
    // Write Back Multiplexer
    assign result = (resultSrc) ? readData : aluResult;



endmodule
