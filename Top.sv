

module top(input logic clk, reset,
           output logic [31:0] WriteDataM, DataAdrM,
           output logic MemWriteM);
 
 logic [31:0] PCF, InstrF, ReadDataM;

 // instantiate processor and memories
 //module ARM(input logic clk, r,output logic [31:0] PCF,input logic [31:0] InstrF,output logic MemWriteM,output logic [31:0] ALUOutM, WriteDataM,input logic [31:0] ReadDataM); //cont, dp, hazard
 ARM myarm(clk, reset, PCF, InstrF, MemWriteM, DataAdrM, WriteDataM, ReadDataM);
 //module imem(input  logic [31:0] a, output logic [31:0] rd);
 imem myimem(PCF, InstrF);
 //module dmem(input  logic clk, we, input  logic [31:0] a, wd, output logic [31:0] rd);
 dmem mydmem(clk, MemWriteM, DataAdrM, WriteDataM, ReadDataM);

endmodule

