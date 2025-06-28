module top(
   input clk,
   input rst,
	input rst_rf,
   input en,
	input en_rf,
	input selec_mux,
   input selec_mux2,
	input [3:0 ] alu_op,
	
	output [31:0] fim
    
);

wire [31:0] q;
wire [31:0] d;
wire [4:0] rW_w;
wire [4:0] rs_w;
wire [4:0] rt_w;
wire [4:0] rd_w;
wire [15:0] immediate_w;
wire [31:0] c_w;



wire [31:0] rfb;

wire [31:0] sin_ex_w;


wire [31:0] rd1_w;
wire [31:0] rd2_w;


pc pc_inst(
    .clk(clk),
    .rst(rst),
    .d(d),
    .en(en),
    .q(q)
);

somador som_inst(
    .a(q),
    .b(d)
);

memoria_instrucao mi_inst(
	.pc(q),
	.instruction(),
	.op(),
	.rs(rs_w),
	.rt(rt_w),
	.rd(rd_w),
	.immediate(immediate_w)
);
register_file reg_file(
	.clk(clk),
	.rst(rst_rf),
	.en(en_rf),
	.rA(rs_w),
	.rB(rt_w),
	.rW(rW_w),
	.Wd(c_w),
	.rD1(rd1_w),
	.rD2(rd2_w)
);
alu alu_inst(
	.a(rd1_w),
	.b(rfb),
	.op(alu_op),
	.c(c_w)

);
sinal_ex sinal_ex_inst(
	.a(immediate_w),
	.b(sin_ex_w)
);

assign rW_w = selec_mux ? rd_w : rs_w;
assign rfb = selec_mux2 ? sin_ex_w: rd2_w;
assign fim = c_w;


endmodule
