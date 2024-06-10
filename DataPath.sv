module IsEqual 
#(parameter n = 32)
(input logic [n-1:0] a, b,
output logic y);
assign y = (a == b);
endmodule



module DataPath(input logic clk, reset,
                input logic [1:0] RegSrcD,
				input logic [1:0] ImmSrcD,
                input logic ALUSrcE,
				input logic BranchTakenE,
                input logic [2:0] ALUControlE,
                input logic MemtoRegW,
				input logic PCSrcW,
				input logic RegWriteW,
                output logic [31:0] PCF,
                input logic [31:0] InstrF,
                output logic [31:0] InstrD,
                output logic [31:0] ALUOutM,
				output logic [31:0] WriteDataM,
                input logic [31:0] ReadDataM,
                output logic [3:0] ALUFlagsE,
               //----------------hazards-------------//
                output logic Match_1E_M,
				output logic Match_1E_W,
				output logic Match_2E_M,
				output logic Match_2E_W,
				output logic Match_12D_E,
                input logic [1:0] ForwardAE, ForwardBE,
                input logic StallF,
				input logic StallD,
				input logic FlushD);

 logic [31:0] PCPlus4F, PCnext1F, PCnextF;
 logic [31:0] ExtImmD, rd1D, rd2D, PCPlus8D;
 logic [31:0] rd1E, rd2E, ExtImmE, SrcAE, SrcBE, WriteDataE, ALUResultE;
 logic [31:0] ReadDataW, ALUOutW, ResultW;
 logic [3:0] RA1D, RA2D, RA1E, RA2E, WA3E, WA3M, WA3W;
 logic Match_1D_E, Match_2D_E;

 //-------------------------------Fetch------------------------//
 mux2 #(32) PCmux(PCPlus4F, ResultW, PCSrcW, PCnext1F);//PC next
 mux2 #(32) Bmux(PCnext1F, ALUResultE, BranchTakenE, PCnextF);//Branch
 flipflop_with_en_r #(32) PCReg(clk, reset, ~StallF, PCnextF, PCF); //PC Register
 logic notimportant;
 Adder #(32) PCAdd(PCF, 32'h4,1'b0, PCPlus4F,notimportant);//PCadd4


 //-----------------------------Decode-------------------------//
 assign PCPlus8D = PCPlus4F; // take a wire from perivous stage
 flop_with_en_r_c #(32) ff1(clk, reset, ~StallD, FlushD, InstrF, InstrD);//InstructionRegister
 mux2 #(4) RA1mux(InstrD[19:16], 4'b1111, RegSrcD[0], RA1D);//muxes for inputs of regfile
 mux2 #(4) RA2mux(InstrD[3:0], InstrD[15:12], RegSrcD[1], RA2D);
 RegisterFile regf(clk, RegWriteW, RA1D, RA2D, WA3W, ResultW, PCPlus8D, rd1D, rd2D);
 Extender E(InstrD[23:0], ImmSrcD, ExtImmD); 
 
 //-----------------------------Execute-------------------------//
 flipflop_with_r #(32) rd1reg(clk, reset, rd1D, rd1E);
 flipflop_with_r #(32) rd2reg(clk, reset, rd2D, rd2E);
 flipflop_with_r #(32) immreg(clk, reset, ExtImmD, ExtImmE);//reg input from extender
 flipflop_with_r #(4) wa3ereg(clk, reset, InstrD[15:12], WA3E);//hazard-ish
 flipflop_with_r #(4) ra1reg(clk, reset, RA1D, RA1E);//hazard-ish
 flipflop_with_r #(4) ra2reg(clk, reset, RA2D, RA2E);//hazard-ish
 mux4 #(32) byp1mux(rd1E, ResultW, ALUOutM,ALUOutM, ForwardAE, SrcAE);//4th input not relevant
 mux4 #(32) byp2mux(rd2E, ResultW, ALUOutM,ALUOutM, ForwardBE, WriteDataE);//4th input not relevant
 mux2 #(32) srcbmux(WriteDataE, ExtImmE, ALUSrcE, SrcBE);
 ALU myalu(SrcAE, SrcBE, ALUControlE, ALUResultE, ALUFlagsE);

 //-----------------------------Memory-------------------------//
 flipflop_with_r #(32) aluresreg(clk, reset, ALUResultE, ALUOutM);
 flipflop_with_r #(32) wdreg(clk, reset, WriteDataE, WriteDataM);
 flipflop_with_r #(4) wa3mreg(clk, reset, WA3E, WA3M);

 //-----------------------------Writeback-------------------------//
 flipflop_with_r #(32) aluout(clk, reset, ALUOutM, ALUOutW);
 flipflop_with_r #(32) rd(clk, reset, ReadDataM, ReadDataW);
 flipflop_with_r #(4) wa3w(clk, reset, WA3M, WA3W);
 mux2 #(32) res(ALUOutW, ReadDataW, MemtoRegW, ResultW);//resultmux

 //-----------------------------Hazards-------------------------//
 IsEqual #(4) ie0(WA3M, RA1E, Match_1E_M);
 IsEqual #(4) ie1(WA3W, RA1E, Match_1E_W);
 IsEqual #(4) ie2(WA3M, RA2E, Match_2E_M);
 IsEqual #(4) ie3(WA3W, RA2E, Match_2E_W);
 IsEqual #(4) ie4a(WA3E, RA1D, Match_1D_E);
 IsEqual #(4) ie4b(WA3E, RA2D, Match_2D_E);
 assign Match_12D_E = Match_1D_E | Match_2D_E;

endmodule
