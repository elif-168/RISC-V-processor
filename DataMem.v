module DataMemory(
    input clk, // Clock 
    input we, // Write enable 
    input [31:0] wd, // Data to write
    input [31:0] addr,  // Memory address

    output reg [31:0] dataOut // Data read as output
);

    // 256 x 32-bit memory array
    reg [31:0] data [0:255];

    
    initial begin
        $readmemh("Data.txt", data); // Load memory from a txt file in hex form
    end

    // Read data from memory
    always @(*) begin
        dataOut = data[addr[7:0]]; // Use the lower 8 bits of address for indexing
    end

    // Write data to memory on positive clock edge
    always @(posedge clk) begin
        if (we) begin
            data[addr[7:0]] <= wd; // Write data at the specified address
        end
    end

endmodule
