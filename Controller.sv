module Controller(input logic clk, reset,
                  input logic [31:12] InstrD,
                  input logic [3:0] ALUFlagsE,
                  
                  output logic [1:0] RegSrcD, ImmSrcD,
                  output logic ALUSrcE,
				  output logic BranchTakenE,
                  output logic [2:0] ALUControlE,
                  output logic MemWriteM,
                  output logic MemtoRegW,
				  output logic PCSrcW,
				  output logic RegWriteW,
                  //--------hazard-----------// 
                  output logic RegWriteM, MemtoRegE,
                  output logic PCWrPendingF,
                  input logic FlushE);


logic [9:0] controlsD;
logic CondExE, ALUOpD,ALUSrcD,MemtoRegD, MemtoRegM,RegWriteD, RegWriteE, RegWriteGatedE,MemWriteD, MemWriteE, MemWriteGatedE,BranchD, BranchE,PCSrcD, PCSrcE, PCSrcM;                   
logic [2:0] ALUControlD;                                   
logic [1:0] FlagWriteD, FlagWriteE;                  
logic [3:0] FlagsE, FlagsNextE, CondE;
 


//-----------------Decode-----------------//
always_comb
	casex(InstrD[27:26])
		2'b00: if (InstrD[25]) controlsD = 10'b0000101001; // immdieat
			else controlsD = 10'b0000001001; // regiester
		2'b01: if (InstrD[20]) controlsD = 10'b0001111000; // LDR
			else controlsD = 10'b1001110100; // STR
		2'b10: controlsD = 10'b0110100010; // Branch
		default: controlsD = 10'bx; //unkown
	endcase

 assign {RegSrcD, ImmSrcD, ALUSrcD, MemtoRegD, RegWriteD, MemWriteD, BranchD, ALUOpD} = controlsD;
 
//extend to include BIC & EOR
 always_comb
 if (ALUOpD) begin 
	case(InstrD[24:21])
		4'b0100: ALUControlD = 3'b000; // ADD
		4'b0010: ALUControlD = 3'b001; // SUB
		4'b0000: ALUControlD = 3'b010; // AND
		4'b1100: ALUControlD = 3'b011; // ORR
		4'b0001: ALUControlD = 3'b100; // EOR
		4'b1110: ALUControlD = 3'b110; // BIC
		default: ALUControlD = 3'bx; // unkown
 	endcase
FlagWriteD[1] = InstrD[20]; // update N and Z Flags if S
FlagWriteD[0] = InstrD[20] & (ALUControlD == 3'b000 | ALUControlD == 3'b001);// update C and V Flags if add or sub
 end 
else begin
	ALUControlD = 3'b000; // addition in case of nondataprocessing 
	FlagWriteD = 2'b00; 
 end

 assign PCSrcD = (((InstrD[15:12] == 4'b1111) & RegWriteD));


 //-----------------Execute-----------------//
 flop_with_en_r_c #(7) ff1(clk, reset,1'b1, FlushE, {FlagWriteD, BranchD, MemWriteD, RegWriteD, PCSrcD, MemtoRegD}, {FlagWriteE, BranchE, MemWriteE, RegWriteE, PCSrcE, MemtoRegE});//flushed reg 
 flop_with_r #(4) ff2(clk, reset, {ALUSrcD, ALUControlD}, {ALUSrcE, ALUControlE});//reg 
 flop_with_r #(4) ff3(clk, reset, InstrD[31:28], CondE);//condtion reg 
 flop_with_r #(4) ff4(clk, reset, FlagsNextE, FlagsE);//flags reg

 //-------write and Branch controls-------//
 CondCheck Cond(CondE, FlagsE, ALUFlagsE, FlagWriteE, CondExE, FlagsNextE);
 assign BranchTakenE = BranchE & CondExE;
 assign RegWriteGatedE = RegWriteE & CondExE;
 assign MemWriteGatedE = MemWriteE & CondExE;
 assign PCSrcGatedE = PCSrcE & CondExE;

//-----------------Memory-----------------//
 flop_with_r #(4) ff5(clk, reset, {MemWriteGatedE, MemtoRegE, RegWriteGatedE, PCSrcGatedE}, {MemWriteM, MemtoRegM, RegWriteM, PCSrcM});

//-----------------Writeback-----------------//
 flop_with_r #(3) ff6(clk, reset, {MemtoRegM, RegWriteM, PCSrcM}, {MemtoRegW, RegWriteW, PCSrcW});

 //----------Hazard estimation---------------//
 assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;

endmodule 
