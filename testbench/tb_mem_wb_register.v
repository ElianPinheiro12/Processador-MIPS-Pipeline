`timescale 1ns / 1ps

module tb_mem_wb_register;

    // Entradas
    reg clk;
    reg rst;
    reg en;

    reg [31:0] read_data_mem;
    reg [31:0] alu_result_mem;
    reg [4:0]  write_reg_addr_mem;

    reg ctrl_MemToReg_mem;
    reg ctrl_RegWrite_mem;

    // Saídas
    wire [31:0] read_data_wb;
    wire [31:0] alu_result_wb;
    wire [4:0]  write_reg_addr_wb;

    wire ctrl_MemToReg_wb;
    wire ctrl_RegWrite_wb;

    // Instancia o módulo
    mem_wb_register uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .read_data_mem(read_data_mem),
        .alu_result_mem(alu_result_mem),
        .write_reg_addr_mem(write_reg_addr_mem),
        .ctrl_MemToReg_mem(ctrl_MemToReg_mem),
        .ctrl_RegWrite_mem(ctrl_RegWrite_mem),
        .read_data_wb(read_data_wb),
        .alu_result_wb(alu_result_wb),
        .write_reg_addr_wb(write_reg_addr_wb),
        .ctrl_MemToReg_wb(ctrl_MemToReg_wb),
        .ctrl_RegWrite_wb(ctrl_RegWrite_wb)
    );

    // Clock de 10ns
    always #5 clk = ~clk;

    initial begin
        $display("==== Início do Testbench ====");

        // Inicializações
        clk = 0;
        rst = 0;
        en  = 1;

        read_data_mem       = 32'hDEADBEEF;
        alu_result_mem      = 32'hCAFEBABE;
        write_reg_addr_mem  = 5'd15;

        ctrl_MemToReg_mem   = 1;
        ctrl_RegWrite_mem   = 1;

        // ---- Teste 1: Reset ----
        rst = 1;
        #10;
        rst = 0;
        $display("Após reset:");
        $display("  read_data_wb = %h (esperado 0)", read_data_wb);
        $display("  alu_result_wb = %h (esperado 0)", alu_result_wb);
        $display("  write_reg_addr_wb = %d (esperado 0)", write_reg_addr_wb);
        $display("  ctrl_RegWrite_wb = %b (esperado 0)", ctrl_RegWrite_wb);

        // ---- Teste 2: Escrita normal ----
        #10;
        $display("Após escrita normal:");
        $display("  read_data_wb = %h (esperado DEADBEEF)", read_data_wb);
        $display("  alu_result_wb = %h (esperado CAFEBABE)", alu_result_wb);
        $display("  write_reg_addr_wb = %d (esperado 15)", write_reg_addr_wb);
        $display("  ctrl_MemToReg_wb = %b (esperado 1)", ctrl_MemToReg_wb);

        // ---- Teste 3: en = 0 (stall) ----
        en = 0;
        read_data_mem      = 32'hAAAAAAAA;
        alu_result_mem     = 32'hBBBBBBBB;
        write_reg_addr_mem = 5'd7;
        ctrl_RegWrite_mem  = 0;

        #10;
        $display("Com en = 0 (esperado manter valores anteriores):");
        $display("  read_data_wb = %h (esperado DEADBEEF)", read_data_wb);
        $display("  alu_result_wb = %h (esperado CAFEBABE)", alu_result_wb);
        $display("  write_reg_addr_wb = %d (esperado 15)", write_reg_addr_wb);
        $display("  ctrl_RegWrite_wb = %b (esperado 1)", ctrl_RegWrite_wb);

        $display("==== Fim do Testbench ====");
        $stop;
    end

endmodule
