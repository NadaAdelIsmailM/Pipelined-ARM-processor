module flop_with_r
#(parameter n = 32)
(input logic clk, r,
input logic [n-1:0] d,
output logic [n-1:0] q);

always_ff @(posedge clk)
if (r) q <= 0;
else q <= d;

endmodule

module flop_with_en_r 
#(parameter n = 32)
(input logic clk, r, en,
input logic [n-1:0] d,
output logic [n-1:0] q);

always_ff @(posedge clk, posedge r)
if (r) q <= 0;
else if (en) q <= d;//extra check for enable

endmodule

module flop_with_en_r_c #(parameter WIDTH = 8)
(input logic clk, reset, en, clear,
input logic [WIDTH-1:0] d,
output logic [WIDTH-1:0] q);
always_ff @(posedge clk, posedge reset)
if (reset) q <= 0;
else if (en)
if (clear) q <= 0;//extra check for clear
else q <= d;
endmodule

