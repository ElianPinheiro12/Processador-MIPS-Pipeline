
// Arquivo: tb_alu.v
// Descrição: Testbench para a nossa ALU

`timescale 1ns/1ps

module tb_alu;

    // 1. Declare os sinais para conectar na ALU
    // Use 'reg' para as entradas que vamos controlar
    reg [31:0] A_in, B_in;
    reg [3:0]  ALU_ctrl_in;
    
    // Use 'wire' para as saídas que vamos observar
    wire [31:0] Result_out;
    wire        Zero_out;

    // Parâmetros do módulo de teste (os mesmos da ALU)
    parameter OP_ADD = 4'b0010;
    parameter OP_SUB = 4'b0110;
    
    // 2. Instancie a ALU (Device Under Test - DUT)
    // Usamos conexão por nome (.porta_do_modulo(fio_do_testbench))
    alu dut (
        .a(A_in),
        .b(B_in),
        .alu_control(ALU_ctrl_in),
        .result(Result_out),
        .zero(Zero_out)
    );

    // 3. Crie os estímulos de teste
    initial begin
        $display("Iniciando teste da ALU...");

        // Teste 1: Soma (5 + 10 = 15)
        A_in = 32'd5;
        B_in = 32'd10;
        ALU_ctrl_in = OP_ADD;
        #10; // Espera 10 unidades de tempo (10ns)
        $display("SOMA: %d + %d = %d", A_in, B_in, Result_out);

        // Teste 2: Subtração (20 - 7 = 13)
        A_in = 32'd20;
        B_in = 32'd7;
        ALU_ctrl_in = OP_SUB;
        #10;
        $display("SUB: %d - %d = %d", A_in, B_in, Result_out);
        
        // Teste 3: Teste do flag Zero (8 - 8 = 0)
        A_in = 32'd8;
        B_in = 32'd8;
        ALU_ctrl_in = OP_SUB;
        #10;
        $display("ZERO_FLAG: %d - %d = %d. Flag Zero = %b", A_in, B_in, Result_out, Zero_out);
        
        #10;
        $display("Teste concluído.");
        $stop; // Termina a simulação
    end

endmodule
