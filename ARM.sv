module ARM(input logic clk, r,
           output logic [31:0] PCF,
           input logic [31:0] InstrF,
           output logic MemWriteM,
           output logic [31:0] ALUOutM, WriteDataM,
           input logic [31:0] ReadDataM); //cont, dp, hazard

 logic [1:0] RegSrcD, ImmSrcD;
 logic [2:0] ALUControlE;
 logic ALUSrcE, BranchTakenE, MemtoRegW, PCSrcW, RegWriteW;
 logic [3:0] ALUFlagsE;
 logic [31:0] InstrD;
 logic RegWriteM, MemtoRegE, PCWrPendingF;
 logic [1:0] ForwardAE, ForwardBE;
 logic StallF, StallD, FlushD, FlushE;
 logic Match_1E_M, Match_1E_W, Match_2E_M, Match_2E_W, Match_12D_E;
 
 Controller mycont(clk, r, InstrD[31:12], ALUFlagsE, RegSrcD, ImmSrcD, ALUSrcE, BranchTakenE, ALUControlE, MemWriteM, MemtoRegW, PCSrcW, RegWriteW, RegWriteM, MemtoRegE, PCWrPendingF, FlushE);
 //module DataPath(input logic clk, reset,input logic [1:0] RegSrcD,input logic [1:0] ImmSrcD,input logic ALUSrcE,input logic BranchTakenE,input logic [2:0] ALUControlE,input logic MemtoRegW,input logic PCSrcW,input logic RegWriteW,output logic [31:0] PCF,input logic [31:0] InstrF,output logic [31:0] InstrD,output logic [31:0] ALUOutM,output logic [31:0] WriteDataM,input logic [31:0] ReadDataM,output logic [3:0] ALUFlagsE,output logic Match_1E_M,output logic Match_1E_W,output logic Match_2E_M,output logic Match_2E_W,output logic Match_12D_E,input logic [1:0] ForwardAE, ForwardBE,input logic StallF,input logic StallD,input logic FlushD);
 DataPath mydp(clk, r, RegSrcD, ImmSrcD, ALUSrcE, BranchTakenE, ALUControlE, MemtoRegW, PCSrcW, RegWriteW, PCF, InstrF, InstrD, ALUOutM, WriteDataM, ReadDataM, ALUFlagsE, Match_1E_M, Match_1E_W, Match_2E_M, Match_2E_W, Match_12D_E, ForwardAE, ForwardBE, StallF, StallD, FlushD);
 //module Controller(input logic clk, reset,input logic [31:12] InstrD,input logic [3:0] ALUFlagsE,output logic [1:0] RegSrcD, ImmSrcD,output logic ALUSrcE,output logic BranchTakenE,output logic [2:0] ALUControlE,output logic MemWriteM,output logic MemtoRegW,output logic PCSrcW,output logic RegWriteW,output logic RegWriteM, MemtoRegE,output logic PCWrPendingF,input logic FlushE);
 Hazard myhaz(clk, r, Match_1E_M, Match_1E_W, Match_2E_M, Match_2E_W, Match_12D_E, RegWriteM, RegWriteW, BranchTakenE, MemtoRegE, PCWrPendingF, PCSrcW, ForwardAE, ForwardBE, StallF, StallD, FlushD, FlushE);

endmodule 
