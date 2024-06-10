module CondCheck(input logic [3:0] Cond,
                 input logic [3:0] Flags,
                 input logic [3:0] ALUFlags,
                 input logic [1:0] FlagsWrite,
                 output logic CondEx,
                 output logic [3:0] FlagsNext);

 logic neg, zero, carry, overflow;
 always_comb
 case(Cond)
 4'b0000: CondEx = zero;							// EQ                      ////Equal                         Z = 1
 4'b0001: CondEx = ~zero; 							// NE                      ////Not Equal                     Z = 0
 4'b0010: CondEx = carry; 							// CS                      ////Carry Set                     C = 1
 4'b0011: CondEx = ~carry; 							// CC                      ////Carry Clear                   C = 0
 4'b0100: CondEx = neg; 							// MI                      ////Minus                         N = 1
 4'b0101: CondEx = ~neg; 							// PL                      ////Plus                          N = 0
 4'b0110: CondEx = overflow;						// VS                      ////Overflow                      V = 1
 4'b0111: CondEx = ~overflow;						// VC                      ////No Overflow                   V = 0
 4'b1000: CondEx = carry & ~zero;					// HI           	       ////Unsigned Higher               C = 1 & Z = 0
 4'b1001: CondEx = ~(carry & ~zero);				// LS              		   ////Unsigned Lower/Same           C = 0 | Z = 1
 4'b1010: CondEx = (neg == overflow);				// GE             		   ////Signed greater/equal          N = V
4'b1011: CondEx = ~(neg == overflow); 				// LT           		   ////Signed less                   N != V
 4'b1100: CondEx = ~zero & (neg == overflow);		// GT     				   ////Signed greater                N = V & Z = 0
 4'b1101: CondEx = ~(~zero & (neg == overflow));	// LE 		 			   ////Signed less/equal             N != V | Z = 1
 4'b1110: CondEx = 1'b1; 							// Always                  ////unconditional                        any		
 default: CondEx = 1'bx; 							// undefined               ////unkown
 endcase
 assign {neg, zero, carry, overflow} = Flags;
 assign FlagsNext[3:2] = (FlagsWrite[1] & CondEx) ? ALUFlags[3:2] : Flags[3:2];
 assign FlagsNext[1:0] = (FlagsWrite[0] & CondEx) ? ALUFlags[1:0] : Flags[1:0];
endmodule 
