`timescale 1ns / 1ps

module tb_top;

    // Sinais de entrada para o DUT (Device Under Test)
    reg clk;
    reg rst;
    reg rst_rf;
    reg en;
    reg en_rf;
    reg selec_mux;
    reg selec_mux2;
    reg [3:0] alu_op;

    // Sinal de saída do DUT
    wire [31:0] fim;

    // Instanciação do módulo 'top' (Device Under Test)
    top dut (
        .clk(clk),
        .rst(rst),
        .rst_rf(rst_rf),
        .en(en),
        .en_rf(en_rf),
        .selec_mux(selec_mux),
        .selec_mux2(selec_mux2),
        .alu_op(alu_op),
        .fim(fim)
    );

    // 1. Geração do Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Período do clock de 10ns
    end

    // 2. Lógica de Simulação e Estímulos
    initial begin
        // --- Fase de Reset Inicial ---
        $display("T=%0t: Iniciando simulação e aplicando reset...", $time);
        rst = 1;
        rst_rf = 1;
        en = 0;       // PC desabilitado
        en_rf = 0;    // Escrita no banco de registradores desabilitada
        selec_mux = 0;
        selec_mux2 = 0;
        alu_op = 4'b0000; // NOP
        
        #20; // Espera 2 ciclos de clock para o reset propagar
        
        rst = 0;
        rst_rf = 0;
        $display("T=%0t: Fim do reset. Começando execução.", $time);
        
        // --- Ciclo 1: Executar 'addi $1, $zero, 5' (PC = 0) ---
        @(posedge clk);
        $display("--------------------------------------------------");
        $display("T=%0t: Ciclo 1 - Instrução: addi $1, $zero, 5", $time);
        
        // Sinais de controle para ADDI (Tipo-I)
        en = 1;           // Habilita PC para incrementar
        en_rf = 1;        // Habilita escrita no banco de registradores
        alu_op = 4'b0010; // Operação de SOMA na ALU
        selec_mux = 0;    // Seleciona RT como registrador de destino (rW = rt)
        selec_mux2 = 1;   // Seleciona o valor imediato estendido como segundo operando da ALU
        
        #10; // Deixa o ciclo terminar
        $display("T=%0t: Resultado da ALU (fim) = %d. (Esperado: 5)", $time, fim);

        // --- Ciclo 2: Executar 'addi $2, $zero, 10' (PC = 4) ---
        @(posedge clk);
        $display("--------------------------------------------------");
        $display("T=%0t: Ciclo 2 - Instrução: addi $2, $zero, 10", $time);
        
        // Sinais de controle são os mesmos do ADDI anterior
        
        #10;
        $display("T=%0t: Resultado da ALU (fim) = %d. (Esperado: 10)", $time, fim);
        
        // --- Ciclo 3: Executar 'add $3, $1, $2' (PC = 8) ---
        @(posedge clk);
        $display("--------------------------------------------------");
        $display("T=%0t: Ciclo 3 - Instrução: add $3, $1, $2", $time);

        // Sinais de controle para ADD (Tipo-R)
        // en e en_rf continuam em 1
        alu_op = 4'b0010; // Operação de SOMA na ALU
        selec_mux = 1;    // Seleciona RD como registrador de destino (rW = rd)
        selec_mux2 = 0;   // Seleciona o valor de RT (rD2) como segundo operando da ALU
        
        #10;
        $display("T=%0t: Resultado da ALU (fim) = %d. (Esperado: 15)", $time, fim);

        // --- Fim da Simulação ---
        @(posedge clk);
        $display("--------------------------------------------------");
        $display("T=%0t: Fim do programa. Parando simulação.", $time);
        en = 0;
        en_rf = 0;
        #20;
        
        $finish; // Termina a simulação
    end

endmodule
