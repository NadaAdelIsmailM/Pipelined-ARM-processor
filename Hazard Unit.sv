module Hazard(input logic clk, reset,
              input logic Match_1E_M, Match_1E_W, Match_2E_M, Match_2E_W, Match_12D_E,
              input logic RegWriteM, RegWriteW,
              input logic BranchTakenE, MemtoRegE,
              input logic PCWrPendingF, PCSrcW,
 
              output logic [1:0] ForwardAE, ForwardBE,
              output logic StallF, StallD,
              output logic FlushD, FlushE);
 
 logic ldrStallD;
 
//----------forwarding-------------//
 always_comb begin
	if (Match_1E_M & RegWriteM) ForwardAE = 2'b10;
	else if (Match_1E_W & RegWriteW) ForwardAE = 2'b01;
	else ForwardAE = 2'b00;

	if (Match_2E_M & RegWriteM) ForwardBE = 2'b10;
	else if (Match_2E_W & RegWriteW) ForwardBE = 2'b01; 
	else ForwardBE = 2'b00;
 end
//----------stalls and flushes----------//
 assign ldrStallD = Match_12D_E & MemtoRegE;//(****)

 assign StallD = ldrStallD; //(*)
 assign StallF = ldrStallD | PCWrPendingF;//(**)//(***)
 assign FlushE = ldrStallD | BranchTakenE;//(*)//(*****)
 assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE;//(**) //(***)
//(*)(**) if stge stall, stall all before and flush all after
//(***)PC Write Hazard When the PC is overwritten, stall all inst
//(****)(RAW Hazard) dependacy in previous state reg (reads a register writen by the previous stage)
//(*****)if branch, flush the useless fet instructs from E and D stages
endmodule 

