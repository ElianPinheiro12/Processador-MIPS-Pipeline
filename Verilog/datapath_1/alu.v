module alu(
	input wire [31:0] a,
	input wire [31:0] b,
	input wire [3:0 ] op,
	output reg [31:0] c
); 
	parameter OP_AND = 4'b0000;
	parameter OP_OR  = 4'b0001;
	parameter OP_ADD = 4'b0010;
	parameter OP_SUB = 4'b0110;
	parameter OP_SLT = 4'b0111;
	parameter OP_NOR = 4'b1100;

	always@(*)begin 
		case(op) 
		OP_AND: c = a & b;
		OP_OR:  c = a | b;
		OP_ADD: c= a + b;
		OP_SUB: c = a - b;
		OP_SLT: c = (a < b) ? 32'b1 : 32'b0;
		OP_NOR: c = ~(a | b);
		default: c = 32'b0;

		
		endcase
	end


endmodule
