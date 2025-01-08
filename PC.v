module Pc(
    input clk, 
    input [31:0] pc_in, 
    output reg [31:0] pc_out
);

initial begin
    pc_out = 32'h00000000;
end

always @ (posedge clk)
    pc_out <= pc_in;

endmodule