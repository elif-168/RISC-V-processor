module instruction_mem (
    input [31:0] instruction_address,
    output [31:0] instruction
);

    reg [31:0] memory [0:255]; // Memory for 256 instructions, 32 bits each

    initial begin
        $readmemh("instructions.txt", memory); // Load instructions from the file
    end

    // Use the lower 8 bits of the address to access the memory
    assign instruction = memory[instruction_address[7:0]];

endmodule
