module mux2
#(parameter n=8)
(input logic [n-1:0] A,B,
input logic S,
output logic [n-1:0] X);
assign X=S?A:B;
endmodule

module mux4
#(parameter n=8)
(input logic [n-1:0] A,B,C,D,
input logic [1:0] S,
output logic [n-1:0] X);
logic [n-1:0] w1,w2;
mux2 M00(A,B,S[0],w1);
mux2 M01(C,D,S[0],w2);
mux2 M1 (w1,w2,S[1],X);
endmodule

