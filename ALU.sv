module Adder
#(parameter n=32)
(input logic [n-1:0] A,B,
input logic cin,
output logic [n-1:0] sum,
output logic cout);
assign {cout,sum} =A+B;//check this
endmodule

module bit32_AND
#(parameter n=32)
(input logic [n-1:0] A,B,
output logic [n-1:0] X);

assign X=A&B;
endmodule

module bit32_OR
#(parameter n=32)
(input logic [n-1:0] A,B,
output logic [n-1:0] X);

assign X=A|B;

endmodule


module mux2
#(parameter n=32)
(input logic [n-1:0] A,B,
input logic S,
output logic [n-1:0] X);
assign X=S?A:B;
endmodule

module mux4
#(parameter n=32)
(input logic [n-1:0] A,B,C,D,
input logic [1:0] S,
output logic [n-1:0] X);
logic [n-1:0] w1,w2;
mux2 M00(A,B,S[0],w1);
mux2 M01(C,D,S[0],w2);
mux2 M1 (w1,w2,S[1],X);
endmodule


module bit32_INV
#(parameter n=32)
(input logic [n-1:0] A,
input logic [n-1:0] X);

assign X=~A;
endmodule

//module ALU
//#(parameter n=32)
//(input logic [n-1:0] A,B,
//input logic [1:0] ALUC,
//output logic [n-1:0] X);


//logic[n-1:0] B_comp,BB,sum,AandB,AorB;
//logic cout;
//bit32_INV inv(B,B_comp);
//mux2 M2(B,B_comp,ALUC[0],BB);
//bit32_adder ADD( A,BB,ALUC[0],sum,cout);
//bit32_AND and1 (A,B,AandB);
//bit32_OR or1 (A,B,AorB);
//mux4 M4(sum,sum,AandB,AorB,ALUC,X);

//endmodule



module ALU(input logic [31:0] SrcA, SrcB,
           input logic [2:0] ALUControl,
           output logic [31:0] ALUResult,
           output logic [3:0] ALUFlags);

 logic N, Z, C, V;
 logic [31:0] condSrcB ;
 logic [32:0] sum;
 assign condSrcB = ALUControl[0] ? ~SrcB : SrcB;
 assign sum = SrcA + condSrcB + ALUControl[0];

 always_comb
 casex (ALUControl[2:0])
 3'b00?: ALUResult = sum;//Add 	 000 <<=>> SUB 	 001
 3'b010: ALUResult = SrcA & SrcB;//AND 	 010
 3'b011: ALUResult = SrcA | SrcB;//OR  	 011
 3'b100: ALUResult = SrcA ^ SrcB;//EOR 	 100
 3'b110: ALUResult = SrcA & ~SrcB; //BIC 	 110

 endcase

 assign N = ALUResult[31];
 assign Z = (ALUResult == 32'b0);
 assign C = (ALUControl[2:1] == 2'b00) & sum[32];
 assign V = (ALUControl[2:1] == 2'b00) & ~(SrcA[31] ^ SrcB[31] ^ ALUControl[0]) & (SrcA[31] ^ sum[31]);
 assign ALUFlags = {N, Z, C, V};
endmodule
