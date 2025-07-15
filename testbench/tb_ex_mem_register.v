`timescale 1ns / 1ps

module tb_ex_mem_register;

    // Entradas
    reg clk;
    reg rst;
    reg en;

    reg [31:0] alu_result_ex;
    reg [31:0] write_data_ex;
    reg [4:0]  write_reg_addr_ex;

    reg ctrl_MemToReg_ex;
    reg ctrl_RegWrite_ex;
    reg ctrl_MemRead_ex;
    reg ctrl_MemWrite_ex;

    // Saídas
    wire [31:0] alu_result_mem;
    wire [31:0] write_data_mem;
    wire [4:0]  write_reg_addr_mem;

    wire ctrl_MemToReg_mem;
    wire ctrl_RegWrite_mem;
    wire ctrl_MemRead_mem;
    wire ctrl_MemWrite_mem;

    // Instancia o módulo
    ex_mem_register uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .alu_result_ex(alu_result_ex),
        .write_data_ex(write_data_ex),
        .write_reg_addr_ex(write_reg_addr_ex),
        .ctrl_MemToReg_ex(ctrl_MemToReg_ex),
        .ctrl_RegWrite_ex(ctrl_RegWrite_ex),
        .ctrl_MemRead_ex(ctrl_MemRead_ex),
        .ctrl_MemWrite_ex(ctrl_MemWrite_ex),
        .alu_result_mem(alu_result_mem),
        .write_data_mem(write_data_mem),
        .write_reg_addr_mem(write_reg_addr_mem),
        .ctrl_MemToReg_mem(ctrl_MemToReg_mem),
        .ctrl_RegWrite_mem(ctrl_RegWrite_mem),
        .ctrl_MemRead_mem(ctrl_MemRead_mem),
        .ctrl_MemWrite_mem(ctrl_MemWrite_mem)
    );

    // Clock de 10ns
    always #5 clk = ~clk;

    initial begin
        $display("==== Início do Testbench ====");

        // Inicializações
        clk = 0;
        rst = 0;
        en = 1;

        alu_result_ex      = 32'h12345678;
        write_data_ex      = 32'hCAFEBABE;
        write_reg_addr_ex  = 5'd10;

        ctrl_MemToReg_ex   = 1;
        ctrl_RegWrite_ex   = 1;
        ctrl_MemRead_ex    = 1;
        ctrl_MemWrite_ex   = 1;

        // ---- Teste 1: Reset ----
        rst = 1;
        #10;
        rst = 0;

        $display("Após reset:");
        $display("  alu_result_mem = %h", alu_result_mem);
        $display("  ctrl_MemToReg_mem = %b", ctrl_MemToReg_mem);

        // ---- Teste 2: Escrita normal ----
        #10;
        $display("Após escrita normal:");
        $display("  alu_result_mem = %h (esperado 12345678)", alu_result_mem);
        $display("  write_data_mem = %h (esperado CAFEBABE)", write_data_mem);
        $display("  write_reg_addr_mem = %d (esperado 10)", write_reg_addr_mem);
        $display("  ctrl_RegWrite_mem = %b (esperado 1)", ctrl_RegWrite_mem);

        // ---- Teste 3: Disable com en = 0 ----
        en = 0;
        alu_result_ex      = 32'hDEADBEEF;
        write_data_ex      = 32'hABCD1234;
        write_reg_addr_ex  = 5'd20;
        ctrl_RegWrite_ex   = 0;

        #10;
        $display("Com en = 0 (valores não devem mudar):");
        $display("  alu_result_mem = %h (esperado valor anterior)", alu_result_mem);
        $display("  write_reg_addr_mem = %d (esperado 10)", write_reg_addr_mem);

        $display("==== Fim do Testbench ====");
        $stop;
    end

endmodule
