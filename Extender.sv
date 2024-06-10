module Extender(input logic [23:0] A,
input logic [1:0] I,
output logic [31:0] X);
always_comb
case(I)
0: X = {24'b0, A[7:0]};//8bit
1: X = {20'b0, A[11:0]};//12bit
2: X = {{6{A[23]}},A[23:0], 2'b00};//branch
default: X= 32'bx; //not supported
endcase
endmodule
