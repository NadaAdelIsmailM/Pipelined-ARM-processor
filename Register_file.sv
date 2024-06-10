module RegisterFile(input logic clk,
input logic WE3,
input logic [3:0] RA1, RA2, WA3,
input logic [31:0] WD3, R15,
output logic [31:0] Rd1, Rd2);
logic nclk;
assign nclk=~clk;
logic [31:0] registers [14:0];//R15 not included here
// write on the falling edge of clock (so that writing could be red on same cycle instead
always_ff @(posedge nclk)
	if (WE3) registers[WA3] <= WD3;
assign Rd1 = (RA1 == 4'b1111) ? R15 : registers[RA1];
assign Rd2 = (RA2 == 4'b1111) ? R15 : registers[RA2];//r15 = PC+8 
endmodule
