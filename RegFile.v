module reg_file (
    input [4:0] readA1, // number of register to be read
    input [4:0] readA2, // number of register to be read
    input [4:0] writeA3,// number of register to be written
    input [31:0] data, // to write
    input we, //write enable
    input clk,
    
    output[31:0] RD1, // data from read ports
    output [31:0] RD2 
);

    reg [31:0] register[31:0];
    integer i;

    initial begin

    for (i = 0; i < 32; i = i + 1) begin
        register[i] = 32'h00000000;
    end

    end

   
    // assigning the output ports the values from the registers
    // but if the adress is of the 0th reg then directly 0 is assigned to implement 0 register as hardwired to zero
    assign RD1 = (readA1 == 0) ? 32'h00000000 : register[readA1];
    assign RD2 = (readA2 == 0) ? 32'h00000000 : register[readA2];

    always @(posedge clk) begin

        if (we && writeA3 != 0) begin
            register[writeA3] <= data; // output the data 
        end

    end

    
endmodule