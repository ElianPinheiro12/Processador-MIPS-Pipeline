// Arquivo: testbench_top.v
`timescale 1ns / 1ps

module testbench_top;

    // --- Sinais para conectar ao DUT (Device Under Test) ---

    // Entradas do tipo reg, pois são controladas pelo testbench
    reg clk;
    reg rst;
    reg en;

    // Sinais de controle que o testbench vai gerar
    reg Branch;
    reg RegDst;
    reg regWrite;
    reg alu_scr;
    reg [3:0] alu_op;
    reg MemToReg;
    reg MemWrite;
    reg MemRead;

    // Saída do tipo wire para observar o resultado
    wire [31:0] fim;
    
    // --- Instanciação do Módulo Top ---
    // Conecte os regs e wires do testbench às portas do módulo top
    top dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .Branch(Branch),
        .RegDst(RegDst),
        .regWrite(regWrite),
        .alu_scr(alu_scr),
        .alu_op(alu_op),
        .MemToReg(MemToReg),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .fim(fim)
    );

    // --- Geração de Clock ---
    // Cria um clock com período de 10ns (frequência de 100MHz)
    always #5 clk = ~clk;

    // --- Bloco Principal de Simulação ---
    initial begin
        // 1. Inicialização e Reset
        clk = 0;
        rst = 1; // Ativa o reset
        en = 1;  // Habilita o processador
        
        // Inicia todos os sinais de controle em 0 (estado seguro)
        Branch = 0; RegDst = 0; regWrite = 0; alu_scr = 0; alu_op = 4'b0; 
        MemToReg = 0; MemWrite = 0; MemRead = 0;
        
        #20; // Espera 20ns para garantir que o reset se propague
        rst = 0; // Desativa o reset
        
        $display("-------------------------------------------------------------------");
        $display("Tempo(ns)| PC       | Instrução  | regWrite|DestReg| ALU Src|ALU Op| Resultado ALU");
        $display("-------------------------------------------------------------------");

        // 2. Simulação ciclo a ciclo (agindo como a Unidade de Controle)
        
        // --- Ciclo 1: Executa a instrução em PC=0x00 (addi $t0, $zero, 5) ---
        // Sinais de controle para ADDI:
        RegDst   = 0;      // Destino é rt (reg 8)
        regWrite = 1;      // Habilita escrita no banco de registradores
        alu_scr  = 1;      // Segundo operando da ALU é o imediato estendido
        alu_op   = 4'b0010; // Operação da ALU: add
        MemToReg = 0;      // Dado para o reg vem da ALU
        MemWrite = 0;      // Não escreve na memória
        MemRead  = 0;      // Não lê da memória
        Branch   = 0;      // Não é branch
        
        @(posedge clk); // Espera a borda de subida do clock para a instrução executar
        
        // --- Ciclo 2: Executa a instrução em PC=0x04 (addi $t1, $zero, 10) ---
        // Sinais de controle para ADDI (são os mesmos do ciclo anterior)
        RegDst   = 0;
        regWrite = 1;
        alu_scr  = 1;
        alu_op   = 4'b0010; // add
        MemToReg = 0;
        MemWrite = 0;
        MemRead  = 0;
        Branch   = 0;

        @(posedge clk);

        // --- Ciclo 3: Executa a instrução em PC=0x08 (add $s0, $t0, $t1) ---
        // Sinais de controle para ADD (Tipo-R):
        RegDst   = 1;      // Destino é rd (reg 16)
        regWrite = 1;      // Habilita escrita
        alu_scr  = 0;      // Segundo operando da ALU é do banco de registradores (rt)
        alu_op   = 4'b0010; // Operação da ALU: add
        MemToReg = 0;      // Dado para o reg vem da ALU
        MemWrite = 0;      // Não escreve na memória
        MemRead  = 0;      // Não lê da memória
        Branch   = 0;      // Não é branch

        @(posedge clk);
        
        // --- Ciclo 4: Observação final ---
        // Desliga a escrita para evitar comportamento inesperado
        regWrite = 0; 
        @(posedge clk);

        $display("-------------------------------------------------------------------");
        // Verifica o valor final no registrador $s0 (reg 16)
        // A sintaxe dut.reg_file.registers[16] permite "olhar dentro" do seu design.
        $display("Simulação concluída. Valor final no registrador $s0 (16): %d", dut.reg_file.registers[16]);
        if (dut.reg_file.registers[16] == 15) begin
            $display("TESTE PASSOU! Resultado esperado (15) foi encontrado.");
        end else begin
            $display("TESTE FALHOU! Resultado inesperado.");
        end
        
        $finish; // Termina a simulação
    end

    // --- Monitoramento ---
    // Exibe os valores dos sinais toda vez que o clock sobe
    initial begin
        $monitor("%8d| %h | %h |    %b    |   %2d    |    %b    |  %b  | %h",
                 $time,           // Tempo atual
                 dut.pc_current,  // PC
                 dut.instruction_w, // Instrução sendo "decodificada"
                 dut.regWrite,      // Sinal regWrite
                 dut.rW_w,          // Endereço do registrador de destino final
                 dut.alu_scr,       // Sinal alu_scr
                 dut.alu_op,        // Operação da ALU
                 dut.alu_result);   // Saída da ALU
    end

endmodule
