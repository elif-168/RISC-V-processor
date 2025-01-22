module instruction_mem (
    input [31:0] instruction_address,
    output [31:0] instruction
);

    reg [31:0] memory [0:63]; // Memory for 64 instructions, 32 bits each

    initial begin
        $readmemh("instructions.txt", memory); // Load instructions from the file
    end

   
    assign instruction = memory[instruction_address[31:2]]; // shift 2 or divide by 4 

endmodule
