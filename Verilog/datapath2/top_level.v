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
wire [31:0] alu_result;
wire [31:0] alu_input_b;

wire [31:0] sin_ex_w;
wire [31:0] r_data;


wire [31:0] rdA_w;
wire [31:0] rdB_w;
wire [31:0] mux_mem;

wire [31:0] instruction_w;

//fios para instrucao:
wire [5:0]  op_code_w;
wire [4:0]  instr_rs;
wire [4:0]  instr_rt;
wire [4:0]  instr_rd;
wire [4:0]  shamt_w;
wire [5:0]  funct_w;
wire [15:0] immediate_w;


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
	.instruction(instruction_w)
);

assign op_code_w   = instruction_w[31:26];
assign instr_rs    = instruction_w[25:21]; // Usado pelo banco de registradores e ALU
assign instr_rt    = instruction_w[20:16]; // Usado pelo banco de registradores e mux
assign instr_rd    = instruction_w[15:11]; // Usado pelo mux que escolhe o registrador de escrita
assign funct_w     = instruction_w[5:0];   // Usado pela unidade de controle/ALU control
assign immediate_w = instruction_w[15:0]; // Usado para operações imediatas




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
