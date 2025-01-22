module control_unit (
    input [6:0] op,
    input [2:0] funct3,
    input [2:0]funct7, // 
    input zero,
    input branch_taken,

    output reg pcSrc,
    output reg resultSrc,
    output reg memWrite,
    output reg [5:0] aluControl, 
    output reg aluSrc,
    output reg [2:0] immSrc,
    output reg regWrite
);

    // Defining opcodes for instruction types
    localparam R_TYPE  = 7'b0110011;
    localparam I_JALR  = 7'b1100111;
    localparam I_LOAD  = 7'b0000011;
    localparam I_ALU   = 7'b0010011;
    localparam I_FENCE = 7'b0001111;
    localparam I_ECALL = 7'b1110011;
    localparam S_TYPE  = 7'b0100011;
    localparam U_LUI   = 7'b0110111;
    localparam U_AUIPC = 7'b0010111;
    localparam B_TYPE  = 7'b1100011;
    localparam J_TYPE  = 7'b1101111;

    always @(*) begin   
        // Default values for control signals
        pcSrc      = 0;
        resultSrc  = 0;
        memWrite   = 0;
        aluControl = 6'b000000;
        aluSrc     = 0;
        immSrc     = 3'b000;
        regWrite   = 0;

        case (op)
            R_TYPE: begin
                regWrite   = 1;
                aluSrc     = 0;
                immSrc     = 3'b000;
                resultSrc  = 0;
                memWrite   = 0;
                pcSrc      = 0;
                // ALU control based on funct3 and funct7
                case (funct3)
                    3'b000: aluControl = (funct7 == 1) ? 6'b000001 : 6'b000000; // SUB/ADD
                    3'b111: aluControl = 6'b000010; // AND
                    3'b001: aluControl = 6'b000110; // SLL
                    3'b010: aluControl = 6'b000101; // SLT
                     
                    
                    3'b011:
                        case(funct7)
                            3'b000: aluControl = 6'b100111;//MUL
                            3'b001: aluControl = 6'b101000;//MULH
                            3'b010: aluControl = 6'b101001;//MULHU
                            3'b011: aluControl = 6'b101010;//MULHSU
                            3'b100: aluControl = 6'b101011;//DIV
                            3'b101: aluControl = 6'b101100;//DIVU
                            3'b110: aluControl = 6'b101101;//REM
                            3'b111: aluControl = 6'b101110;//REMU
                        endcase
                    3'b100:
                        case(funct7)
                            3'b000: aluControl = 6'b000100;//XOR
                            3'b001: aluControl = 6'b001000;//SRL
                            3'b010: aluControl = 6'b001001;//SRA
                            3'b011: aluControl = 6'b001010;//ANDN
                            3'b100: aluControl = 6'b001011;//ORN
                            3'b101: aluControl = 6'b001100;//XNOR
                            3'b110: aluControl = 6'b001101;//REV8
                            3'b111: aluControl = 6'b001110;//ROL
                        endcase
                    3'b101:
                        case(funct7)
                            3'b000: aluControl = 6'b001111;//ROR
                            3'b001: aluControl = 6'b010000;//ROL16
                            3'b010: aluControl = 6'b010001;//ROR16
                            3'b011: aluControl = 6'b010010;//SH1ADD
                            3'b100: aluControl = 6'b010011;//SH2ADD
                            3'b101:aluControl = 6'b000111; // SLTU
                            3'b110: aluControl = 6'b010101;//BINV
                            3'b111: aluControl = 6'b010110;//BCLR
                        endcase 
                    3'b111:
                        case(funct7)
                            3'b000: aluControl = 6'b010111;//BSET
                            3'b001: aluControl = 6'b011000;//MAX
                            3'b010: aluControl = 6'b011001;//MIN
                            3'b011: aluControl = 6'b011010;//MAXU
                            3'b100: aluControl = 6'b011011;//MINU
                            3'b101: aluControl = 6'b011100;//ORC.B
                            3'b110: aluControl = 6'b011101;//SEXT.B
                            3'b111: aluControl = 6'b011110;//SEXT.H
                        endcase 
                    3'b110: 
                        case(funct7)
                            3'b000: aluControl = 6'b011111;//ZEXT.H 
                            3'b001: aluControl = 6'b100000;//CPOP
                            3'b010: aluControl = 6'b100001;//CLZ
                            3'b011: aluControl = 6'b100010;//CTZ
                            3'b100: aluControl = 6'b000011; // OR
                            3'b101: aluControl = 6'b010100;//SH3ADD
                           
                        endcase 
                                                     
                    default: aluControl = 6'b000000; // Default to ADD
                endcase
            end

            I_JALR: begin
                pcSrc      = 1;
                regWrite   = 1;
                resultSrc  = 1;
                aluSrc     = 1;
                immSrc     = 3'b000;
                aluControl = 6'b110110;
            end

            I_LOAD: begin
                regWrite   = 1;
                aluSrc     = 1;
                immSrc     = 3'b001;
                resultSrc  = 1;
                aluControl = 6'b000000; // ADD for address calculation
            end

           I_ALU: begin
                regWrite   = 1;
                aluSrc     = 1;
                immSrc     = 3'b001;
                resultSrc  = 0;
                case (funct3)
                    3'b000: aluControl = 6'b000000; // ADDI
                    3'b010: aluControl = 6'b000101; // SLTI
                    3'b011: aluControl = 6'b000111; // SLTIU
                    3'b100: aluControl = 6'b000100; // XORI
                    3'b110: aluControl = 6'b000011; // ORI
                    3'b111: aluControl = 6'b000010; // ANDI
                    3'b001: aluControl = 6'b000110; // SLLI
                    3'b101: begin
                        case (funct7)
                            3'b000: aluControl = 6'b001000; // SRLI
                            3'b001: aluControl = 6'b001001; // SRAI
                            default: aluControl = 6'bxxxxxx; // Undefined
                        endcase
                    end
                    default: aluControl = 6'bxxxxxx; // Undefined
                endcase
            end


            S_TYPE: begin
                memWrite   = 1;
                aluSrc     = 1;
                immSrc     = 3'b010;
                aluControl = 6'b000000; // ADD for address calculation
            end

            U_LUI: begin
                pcSrc      = 0;
                regWrite   = 1;
                aluSrc     = 0;
                immSrc     = 3'b011;
                resultSrc  = 0;
            end

            U_AUIPC: begin
                regWrite   = 1;
                pcSrc      = 0;
                aluSrc     = 1;
                immSrc     = 3'b011;
                aluControl = 6'b000000; // ADD
            end

            B_TYPE: begin
                //pcSrc      = (zero) ? 1 : 0;
                //pcSrc      = branch_taken;
                pcSrc = 1;
                immSrc     = 3'b000;
                aluSrc     = 0;
                case (funct3)
                    3'b000: aluControl = 6'b101111; // BEQ
                    3'b001: aluControl = 6'b110000; // BNE
                    3'b010: aluControl = 6'b110001; // BLT
                    3'b011: aluControl = 6'b110010; // BGE
                    3'b100: aluControl = 6'b110011; // BLTU
                    3'b101: aluControl = 6'b110100; // BGEU
                    default: aluControl = 6'b000000; 
                endcase
            end

            J_TYPE: begin //JAL
                pcSrc      = 1;
                regWrite   = 1;
                resultSrc  = 1;
                immSrc     = 3'b100;
                aluControl = 6'b110101;
            end

            default: begin
                // Default values (NOP)
                pcSrc      = 0;
                resultSrc  = 0;
                memWrite   = 0;
                aluControl = 6'b000000;
                aluSrc     = 0;
                immSrc     = 2'b00;
                regWrite   = 0;
            end
        endcase
    end

endmodule
