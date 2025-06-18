`timescale 1ns / 1ps

module tb_register_file;

    // --- Sinais de Teste ---
    // regs para as entradas do módulo sob teste (DUT - Device Under Test)
    reg         clk;
    reg         rst;
    reg         RegWrite;
    reg  [4:0]  ReadAddress1;
    reg  [4:0]  ReadAddress2;
    reg  [4:0]  WriteAddress;
    reg  [31:0] WriteData;

    // wires para as saídas do DUT
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    // --- Instanciação do Módulo ---
    // Conectando os sinais do testbench às portas do register_file
    register_file uut (
        .clk(clk),
        .rst(rst),
        .RegWrite(RegWrite),
        .ReadAddress1(ReadAddress1),
        .ReadAddress2(ReadAddress2),
        .WriteAddress(WriteAddress),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // --- Geração do Clock ---
    // Gera um clock com período de 10ns (frequência de 100MHz)
    initial begin
        clk = 0;
    end
    always #5 clk = ~clk;

    // --- Sequência Principal de Testes ---
    initial begin
        // Configuração inicial para a simulação (geração de arquivo de onda)
        $dumpfile("tb_register_file.vcd");
        $dumpvars(0, tb_register_file);

        // ===== TESTE 1: Reset do Sistema =====
        $display("--------------------------------------------------");
        $display("INICIO DOS TESTES");
        $display("--------------------------------------------------");
        $display("\n[TESTE 1] Aplicando Reset...");

        rst = 1;          // Ativa o reset
        RegWrite = 0;     // Desabilita a escrita
        WriteAddress = 5'd0;
        WriteData = 32'd0;
        ReadAddress1 = 5'd1; // Lê um registrador qualquer
        ReadAddress2 = 5'd2; // Lê outro registrador

        @(posedge clk);   // Espera uma borda de subida do clock para o reset ser efetivado
        #1; // Pequeno atraso para garantir a propagação do sinal

        // Verificação: Todos os registradores devem ser zero após o reset
        if (ReadData1 === 32'b0 && ReadData2 === 32'b0) begin
            $display("[TESTE 1] SUCESSO: Registradores zerados corretamente após o reset.");
        end else begin
            $display("[TESTE 1] FALHA: Registradores não foram zerados. ReadData1=%h, ReadData2=%h", ReadData1, ReadData2);
        end
        
        rst = 0; // Libera o reset para iniciar a operação normal
        @(negedge clk); // Sincroniza com a borda de descida para o próximo teste


        // ===== TESTE 2: Escrita e Leitura Simples =====
        $display("\n[TESTE 2] Escrevendo 0xDEADBEEF no registrador R5...");
        
        RegWrite <= 1;                      // Habilita a escrita
        WriteAddress <= 5'd5;               // Endereço do registrador R5
        WriteData <= 32'hDEADBEEF;          // Dado a ser escrito

        // Prepara para ler o valor que acabamos de escrever
        ReadAddress1 <= 5'd5;
        ReadAddress2 <= 5'd6; // Lê um registrador vizinho (deve ser 0)
        
        @(posedge clk); // A escrita ocorre nesta borda de subida
        #1; // Atraso para verificação

        // Verificação
        if (ReadData1 === 32'hDEADBEEF) begin
            $display("[TESTE 2] SUCESSO: Leitura de R5 retornou 0xDEADBEEF.");
        end else begin
            $display("[TESTE 2] FALHA: Leitura de R5 retornou %h. Esperado: 0xDEADBEEF.", ReadData1);
        end
        
        RegWrite <= 0; // Desabilita a escrita para evitar escritas indesejadas
        @(negedge clk);


        // ===== TESTE 3: Escrita em Outro Registrador e Leitura Simultânea =====
        $display("\n[TESTE 3] Escrevendo 0x12345678 em R10 e lendo R5 e R10...");

        RegWrite <= 1;                      // Habilita a escrita
        WriteAddress <= 5'd10;              // Endereço do registrador R10
        WriteData <= 32'h12345678;          // Novo dado
        
        // Vamos ler o valor antigo (R5) e o que será escrito (R10)
        ReadAddress1 <= 5'd5;
        ReadAddress2 <= 5'd10;

        @(posedge clk);
        #1;
        
        // Verificação
        if (ReadData1 === 32'hDEADBEEF && ReadData2 === 32'h12345678) begin
            $display("[TESTE 3] SUCESSO: R5 manteve 0xDEADBEEF e R10 foi atualizado para 0x12345678.");
        end else begin
            $display("[TESTE 3] FALHA: R5=%h (esperado: DEADBEEF), R10=%h (esperado: 12345678)", ReadData1, ReadData2);
        end

        RegWrite <= 0;
        @(negedge clk);


        // ===== TESTE 4: Tentativa de Escrita no Registrador Zero (R0) =====
        $display("\n[TESTE 4] Tentando escrever 0xFFFFFFFF no registrador R0 (deve falhar)...");
        
        RegWrite <= 1;
        WriteAddress <= 5'd0;               // Endereço do registrador R0
        WriteData <= 32'hFFFFFFFF;          // Dado que não deve ser escrito
        
        ReadAddress1 <= 5'd0;               // Lendo R0 para verificar
        
        @(posedge clk);
        #1;

        // Verificação
        if (ReadData1 === 32'b0) begin
            $display("[TESTE 4] SUCESSO: A escrita em R0 foi ignorada e a leitura de R0 retornou 0.");
        end else begin
            $display("[TESTE 4] FALHA: Foi possível escrever em R0! Valor lido: %h.", ReadData1);
        end
        
        RegWrite <= 0;
        @(negedge clk);
        

        // ===== TESTE 5: Verificação da Leitura Assíncrona =====
        $display("\n[TESTE 5] Verificando a natureza assíncrona da leitura...");

        // Não há clock envolvido aqui, apenas mudamos os endereços de leitura
        ReadAddress1 <= 5'd10; // Deve ler 0x12345678
        ReadAddress2 <= 5'd5;  // Deve ler 0xDEADBEEF
        
        #10; // Espera um tempo para que os sinais se propaguem (sem clock)

        // Verificação
        if (ReadData1 === 32'h12345678 && ReadData2 === 32'hDEADBEEF) begin
            $display("[TESTE 5] SUCESSO: As portas de leitura foram atualizadas corretamente sem um ciclo de clock.");
        end else begin
            $display("[TESTE 5] FALHA: Leitura assíncrona não funcionou. R1=%h, R2=%h", ReadData1, ReadData2);
        end

        // ===== Fim dos Testes =====
        $display("\n--------------------------------------------------");
        $display(">>> Testbench concluído com sucesso! <<<");
        $display("--------------------------------------------------");
        $finish; // Termina a simulação
    end

endmodule
