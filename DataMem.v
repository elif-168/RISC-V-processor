
module DataMemory(
    input clk,              // Clock 
    input we,               // Write enable 
    input [31:0] wd,        // Data to write
    input [31:0] addr,      // Memory address
    input [2:0] funct3,     // Specifies the operation type (e.g., LB, LH, LW, etc.)
    output reg [31:0] dataOut // Data read as output
);

    // 64 x 32-bit memory array
    reg [31:0] data [0:63];

    // Initialize memory
    initial begin
        $readmemh("Data.txt", data); // Load memory from a text file in hex form
    end

    // Read data from memory
    always @(*) begin
        case (funct3)
            3'b000: dataOut = {{24{data[addr[31:2]][7]}}, data[addr[31:2]][7:0]};       // LB: Load Byte (Sign-Extend)
            3'b001: dataOut = {{16{data[addr[31:2]][15]}}, data[addr[31:2]][15:0]};     // LH: Load Halfword (Sign-Extend)
            3'b010: dataOut = data[addr[31:2]];                                        // LW: Load Word
            3'b100: dataOut = {24'b0, data[addr[31:2]][7:0]};                          // LBU: Load Byte Unsigned (Zero-Extend)
            3'b101: dataOut = {16'b0, data[addr[31:2]][15:0]};                         // LHU: Load Halfword Unsigned (Zero-Extend)
            default: dataOut = 32'b0;                                                  // Default case
        endcase
    end

    // Write data to memory on positive clock edge
    always @(posedge clk) begin
        if (we) begin
            case (funct3)
                3'b000: data[addr[31:2]][7:0] <= wd[7:0]; //SB                          // SB: Store Byte
                3'b001: data[addr[31:2]][15:0] <= wd[15:0]; //SH                         // SH: Store Halfword
                3'b010: data[addr[31:2]] <= wd;  //SW                       // SW: Store Word
            endcase
        end
    end

endmodule


/*
module DataMemory(
    input clk,              // Clock 
    input we,               // Write enable 
    input [31:0] wd,        // Data to write
    input [31:0] addr,      // Memory address
    input [2:0] funct3,     // Specifies the operation type (e.g., LB, LH, LW, etc.)
    output reg [31:0] dataOut // Data read as output
);

    // 1024 x 8-bit memory array (byte-addressable memory)
    reg [7:0] data [0:64];

    initial begin
        $readmemh("Data.txt", data); // Load memory from a txt file in hex form
    end

    // Read data from memory
    always @(*) begin
        case (funct3)
            3'b000: dataOut = {{24{data[addr][7]}}, data[addr]};                        // LB: Load Byte (Sign-Extend)
            3'b001: dataOut = {{16{data[addr + 1][7]}}, data[addr + 1], data[addr]};    // LH: Load Halfword (Sign-Extend)
            3'b010: dataOut = {data[addr + 3], data[addr + 2], data[addr + 1], data[addr]}; // LW: Load Word
            3'b100: dataOut = {24'b0, data[addr]};                                     // LBU: Load Byte Unsigned (Zero-Extend)
            3'b101: dataOut = {16'b0, data[addr + 1], data[addr]};                     // LHU: Load Halfword Unsigned (Zero-Extend)
            default: dataOut = 32'b0;                                                  // Default case
        endcase
    end

    // Write data to memory on positive clock edge
    always @(posedge clk) begin
        if (we) begin
            case (funct3)
                3'b000: data[addr] <= wd[7:0];                                         // SB: Store Byte
                3'b001: begin                                                          // SH: Store Halfword
                    data[addr] <= wd[7:0];
                    data[addr + 1] <= wd[15:8];
                end
                3'b010: begin                                                          // SW: Store Word
                    data[addr] <= wd[7:0];
                    data[addr + 1] <= wd[15:8];
                    data[addr + 2] <= wd[23:16];
                    data[addr + 3] <= wd[31:24];
                end
            endcase
        end
    end

endmodule

*/


/*
module DataMemory(
    input clk, // Clock 
    input we, // Write enable 
    input [31:0] wd, // Data to write
    input [31:0] addr,  // Memory address
    //input [2:0] funct3,     // Specifies the operation type 

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

*/
