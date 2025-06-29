module top(
	input clk,
    input rst,
    input en,

    //Unidade de Controle
	input Branch,
	input RegDst,
	input regWrite,
	input alu_scr,
	input [3:0 ] alu_op,
	input MemToReg,
	input MemWrite,
	input MemRead,
	output [31:0] fim
    
);

wire [31:0] pc_current;
wire [31:0] pc_plus_4;
wire [31:0] soma4_result;
wire [31:0] soma_result;
wire [31:0] shiftleft;
wire [4:0] rW_w;
wire [4:0] instr_rs;
wire [4:0] instr_rt;
wire [4:0] instr_rd; 
wire [15:0] immediate_w;
wire [31:0] alu_result;



wire [31:0] alu_input_b;

wire [31:0] sin_ex_w;
wire [31:0] r_data;


wire [31:0] rdA_w;
wire [31:0] rdB_w;
wire [31:0] mux_mem;


pc pc_inst(
    .clk(clk),
    .rst(rst),
    .d(pc_plus_4),
    .en(en),
    .q(pc_current)
);
//somadores
somador som_inst(
    .a(pc_current),
  //.b(constante dentro do modulo)
    .c(soma4_result)
);
somador_ab somAB_inst(
	.a_in(soma4_result),
	.b_in(shiftleft),
	.c_out(soma_result)
);

//mux
assign pc_plus_4 = Branch? soma_result: soma4_result;

memoria_instrucao mi_inst(
	.pc(pc_current),
	.instruction(),
	.op(),
	.rs(instr_rs),
	.rt(instr_rt),
	.rd(instr_rd),
	.immediate(immediate_w)
);
//banco registrador
register_file reg_file(
	.clk(clk),
	.rst(rst),
	.en(regWrite),
	.rA(instr_rs), 
	.rB(instr_rt),
	.rW(rW_w),
	.Wd(mux_mem),
	.rD1(rdA_w),
	.rD2(rdB_w)
);

//mux
assign rW_w = RegDst ? instr_rd : instr_rt;

alu alu_inst(
	.a(rdA_w),
	.b(alu_input_b),
	.op(alu_op),
	.c(alu_result) 

);
sinal_ex sinal_ex_inst(
	.a(immediate_w),
	.b(sin_ex_w)
);

//mux
assign alu_input_b = alu_scr ? sin_ex_w: rdB_w;

//mux 
assign mux_mem = MemToReg? r_data: alu_result;

shift_left_2 shift_left_inst(
	.in(sin_ex_w),
	.out(shiftleft)

);
//memoria de dados (memoria ram)
data_memory data_mem_inst(
	.clk(clk),
	.MemWrite(MemWrite),
	.MemRead(MemRead),
	.address(alu_result),
	.write_data(rdB_w),
	.read_data(r_data)
	

);
assign fim = alu_result;


endmodule
