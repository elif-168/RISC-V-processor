module Pc(
    input clk, 
    input reset,
    input [31:0] pc_in, 
    output reg [31:0] pc_out
);

initial begin
    pc_out = 32'h00000000;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out <= 32'h00000000; // Reset PC to 0
    end else begin
        pc_out <= pc_in;        // Update PC with next value
    end
end

endmodule

