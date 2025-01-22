module sign_extend (
    input [31:0] instruction, 
    input [2:0] inst_type,     // the type of the instruction
                        
    output reg [31:0] out    // 32-bit sign-extended immediate
);

    always @(*) begin
        case (inst_type)
            // B-type: 12-bit immediate (bits [31:20])
            3'b000: out = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

            // I-type: 12-bit immediate (bits [31:25 | 11:7])
            3'b001: out = {{20{instruction[31]}}, instruction[31:20]};

            // S-type: 12-bit immediate (bits [31| 7 | 30:25 | 11:8], shifted left by 1)
            3'b010: out = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

            // U-type: 20-bit immediate (bits [31:12], shifted left by 12)
            3'b011: out = {instruction[31:12], 12'b0};

            // J-type: 20-bit immediate (bits [31 | 19:12 | 20 | 30:21], shifted left by 1)
            3'b100: out = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};

            // Default case: zero
            default: out = 32'b0;
        endcase
    end

endmodule
