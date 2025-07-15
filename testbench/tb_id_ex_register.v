`timescale 1ns / 1ps

module tb_id_ex_register;

    // Entradas
    reg clk;
    reg rst;
    reg en;
    reg flush;

    reg [31:0] pc_plus_4_id;
    reg [31:0] read_data_1_id;
    reg [31:0] read_data_2_id;
    reg [31:0] immediate_id;
    reg [4:0]  rs_id;
    reg [4:0]  rt_id;
    reg [4:0]  rd_id;

    reg        ctrl_RegDst_id;
    reg        ctrl_ALUSrc_id;
    reg        ctrl_MemToReg_id;
    reg        ctrl_RegWrite_id;
    reg        ctrl_MemRead_id;
    reg        ctrl_MemWrite_id;
    reg        ctrl_Branch_id;
    reg [5:0]  funct_id;
    reg [1:0]  ctrl_ALUOp_id;

    // Saídas
    wire [31:0] pc_plus_4_ex;
    wire [31:0] read_data_1_ex;
    wire [31:0] read_data_2_ex;
    wire [31:0] immediate_ex;
    wire [4:0]  rs_ex;
    wire [4:0]  rt_ex;
    wire [4:0]  rd_ex;

    wire        ctrl_RegDst_ex;
    wire        ctrl_ALUSrc_ex;
    wire        ctrl_MemToReg_ex;
    wire        ctrl_RegWrite_ex;
    wire        ctrl_MemRead_ex;
    wire        ctrl_MemWrite_ex;
    wire        ctrl_Branch_ex;
    wire [5:0]  funct_ex;
    wire [1:0]  ctrl_ALUOp_ex;

    // Instancia o módulo
    id_ex_register uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .flush(flush),
        .pc_plus_4_id(pc_plus_4_id),
        .read_data_1_id(read_data_1_id),
        .read_data_2_id(read_data_2_id),
        .immediate_id(immediate_id),
        .rs_id(rs_id),
        .rt_id(rt_id),
        .rd_id(rd_id),
        .ctrl_RegDst_id(ctrl_RegDst_id),
        .ctrl_ALUSrc_id(ctrl_ALUSrc_id),
        .ctrl_MemToReg_id(ctrl_MemToReg_id),
        .ctrl_RegWrite_id(ctrl_RegWrite_id),
        .ctrl_MemRead_id(ctrl_MemRead_id),
        .ctrl_MemWrite_id(ctrl_MemWrite_id),
        .ctrl_Branch_id(ctrl_Branch_id),
        .funct_id(funct_id),
        .ctrl_ALUOp_id(ctrl_ALUOp_id),
        .pc_plus_4_ex(pc_plus_4_ex),
        .read_data_1_ex(read_data_1_ex),
        .read_data_2_ex(read_data_2_ex),
        .immediate_ex(immediate_ex),
        .rs_ex(rs_ex),
        .rt_ex(rt_ex),
        .rd_ex(rd_ex),
        .ctrl_RegDst_ex(ctrl_RegDst_ex),
        .ctrl_ALUSrc_ex(ctrl_ALUSrc_ex),
        .ctrl_MemToReg_ex(ctrl_MemToReg_ex),
        .ctrl_RegWrite_ex(ctrl_RegWrite_ex),
        .ctrl_MemRead_ex(ctrl_MemRead_ex),
        .ctrl_MemWrite_ex(ctrl_MemWrite_ex),
        .ctrl_Branch_ex(ctrl_Branch_ex),
        .funct_ex(funct_ex),
        .ctrl_ALUOp_ex(ctrl_ALUOp_ex)
    );

    // Gera clock de 10ns
    always #5 clk = ~clk;

    initial begin
        $display("==== Iniciando Testbench ====");

        // Inicializações
        clk = 0;
        rst = 0;
        en = 1;
        flush = 0;

        pc_plus_4_id   = 32'hAABBCCDD;
        read_data_1_id = 32'h00000011;
        read_data_2_id = 32'h00000022;
        immediate_id   = 32'h00000033;
        rs_id          = 5'd1;
        rt_id          = 5'd2;
        rd_id          = 5'd3;

        ctrl_RegDst_id   = 1;
        ctrl_ALUSrc_id   = 1;
        ctrl_MemToReg_id = 1;
        ctrl_RegWrite_id = 1;
        ctrl_MemRead_id  = 1;
        ctrl_MemWrite_id = 1;
        ctrl_Branch_id   = 1;
        funct_id         = 6'b101010;
        ctrl_ALUOp_id    = 2'b10;

        // ---- Teste 1: Reset ----
        rst = 1;
        #10;   // Espera 1 ciclo de clock
        rst = 0;
        $display("Após reset: pc_plus_4_ex = %h", pc_plus_4_ex);

        // ---- Teste 2: Escrita normal ----
        #10;  // Espera um ciclo de clock
        $display("Após escrita normal: rd_ex = %d", rd_ex);

        // ---- Teste 3: Flush ativo ----
        flush = 1;
        #10;
        flush = 0;
        $display("Após flush: rd_ex = %d (esperado 0)", rd_ex);

        // ---- Teste 4: Enable desabilitado ----
        en = 0;
        pc_plus_4_id = 32'hFFFFFFFF;  // Novos valores não devem ser capturados
        #10;
        $display("Com en=0: pc_plus_4_ex = %h (esperado valor anterior)", pc_plus_4_ex);

        $display("==== Fim do Testbench ====");
        $stop;
    end

endmodule
