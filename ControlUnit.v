module control_unit (
    input [6:0] op,
    input [2:0] funct3,
    input [2:0]funct7, // funct7 taking the bits [31:29] 
    input zero,

    output reg pcSrc,
    output reg resultSrc,
    output reg memWrite,
    output reg [3:0] aluControl, // 6 instructions from R32I + 8 instructions from M extension --> 14 so 4 bits are required
    output reg aluSrc,
    output reg [1:0] immSrc,
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
        // if default value suffices we dont need to write it again in the case selection
        pcSrc      = 0;
        resultSrc  = 0;
        memWrite   = 0;
        aluControl = 4'b0000;
        aluSrc     = 0;
        immSrc     = 2'b00;
        regWrite   = 0;

        case (op)
            R_TYPE: begin
                regWrite   = 1;
                aluSrc     = 0;
                immSrc     = 2'b00;
                resultSrc  = 0;
                memWrite   = 0;
                pcSrc      = 0;
                // ALU control based on funct3 and funct7
                case (funct3)
                    3'b000: aluControl = (funct7 == 1) ? 4'b0001 : 4'b0000; // SUB/ADD
                    3'b111: aluControl = 4'b0100; // AND
                    3'b110: aluControl = 4'b0101; // OR
                    3'b001: aluControl = 4'b0010; // SLL
                    3'b010: aluControl = 4'b0011; // SLT
                    3'b101: aluControl = 4'b1111; // SLTU

                    3'b011:
                        case(funct7)
                            3'b000: aluControl = 4'b0110;//MUL
                            3'b001: aluControl = 4'b0111;//MULH
                            3'b010: aluControl = 4'b1000;//MULHU
                            3'b011: aluControl = 4'b1001;//MULHSU
                        endcase
                    3'b100:
                        case(funct7)
                            3'b000: aluControl = 4'b1011;//DIV
                            3'b001: aluControl = 4'b1100;//DIVU
                            3'b010: aluControl = 4'b1101;//REM
                            3'b011: aluControl = 4'b1110;//REMU
                           
                        endcase
                    
                    default: aluControl = 4'b0000; // Default to ADD
                endcase
            end

            I_JALR: begin
                pcSrc      = 1;
                regWrite   = 1;
                resultSrc  = 1;
                aluSrc     = 1;
                immSrc     = 2'b00;
                aluControl = 4'b0000; // ADD for address calculation
            end

            I_LOAD: begin
                regWrite   = 1;
                aluSrc     = 1;
                immSrc     = 2'b00;
                resultSrc  = 1;
                aluControl = 4'b0000; // ADD for address calculation
            end

            I_ALU: begin
                regWrite   = 1;
                aluSrc     = 1;
                immSrc     = 2'b00;
                resultSrc  = 0;
                case (funct3)
                    3'b000: aluControl = 4'b0000; // ADDI
                    3'b111: aluControl = 4'b0100; // ANDI
                    3'b110: aluControl = 4'b0101; // ORI
                    default: aluControl = 4'b0000;
                endcase
            end

            S_TYPE: begin
                memWrite   = 1;
                aluSrc     = 1;
                immSrc     = 2'b01;
                aluControl = 4'b0000; // ADD for address calculation
            end

            U_LUI: begin
                regWrite   = 1;
                aluSrc     = 0;
                immSrc     = 2'b10;
                resultSrc  = 0;
            end

            U_AUIPC: begin
                regWrite   = 1;
                pcSrc      = 0;
                aluSrc     = 1;
                immSrc     = 2'b10;
                aluControl = 4'b0000; // ADD
            end

            B_TYPE: begin
                pcSrc      = (zero) ? 1 : 0;
                immSrc     = 2'b01;
                aluSrc     = 0;
                case (funct3)
                    3'b000: aluControl = 4'b0001; // BEQ
                    3'b001: aluControl = 4'b0001; // BNE
                    default: aluControl = 4'b0000;
                endcase
            end

            J_TYPE: begin
                pcSrc      = 1;
                regWrite   = 1;
                resultSrc  = 1;
                immSrc     = 2'b11;
            end

            default: begin
                // Default values (NOP)
                pcSrc      = 0;
                resultSrc  = 0;
                memWrite   = 0;
                aluControl = 4'b0000;
                aluSrc     = 0;
                immSrc     = 2'b00;
                regWrite   = 0;
            end
        endcase
    end

endmodule
