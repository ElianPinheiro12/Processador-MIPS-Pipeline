
/*
`timescale 1ns / 1ps
 * Módulo: register_file
 * Descrição: Implementa um banco de 32 registradores de 32 bits para uma CPU MIPS.
 * - 2 portas de leitura assíncronas
 * - 1 porta de escrita síncrona
 * - O registrador $0 é fixo em zero.
 */
module register_file(
    // Entradas de Controle e Clock
    input wire         clk,
    input wire         rst,
    input wire         RegWrite,       // Sinal que habilita a escrita no registrador

    // Entradas para Leitura
    input wire [4:0]   ReadAddress1,   // Endereço do primeiro registrador a ser lido
    input wire [4:0]   ReadAddress2,   // Endereço do segundo registrador a ser lido

    // Entradas para Escrita
    input wire [4:0]   WriteAddress,   // Endereço do registrador a ser escrito
    input wire [31:0]  WriteData,      // Dado a ser escrito

    // Saídas de Dados Lidos
    output wire [31:0] ReadData1,      // Dado lido do ReadAddress1
    output wire [31:0] ReadData2       // Dado lido do ReadAddress2
);

    // Memória interna: 32 registradores, cada um com 32 bits.
    reg [31:0] registers [31:0];

    // Variável de iteração para o reset (uso apenas na inicialização)
    integer i;

    // Lógica de Escrita (Síncrona)
    // A escrita ocorre na borda de subida do clock.
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Em caso de reset, zera todos os registradores
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end 
        else if (RegWrite) begin
            // A escrita só acontece se RegWrite estiver ativo e o endereço não for 0.
            // Isso garante que o registrador $0 permaneça sempre com o valor zero.
            if (WriteAddress != 5'b0) begin
                registers[WriteAddress] <= WriteData;
            end
        end
    end

    // Lógica de Leitura (Assíncrona / Combinacional)
    // A saída é atualizada imediatamente quando o endereço de leitura muda.
    
    // Porta de Leitura 1:
    // Se o endereço for 0, a saída é 0. Caso contrário, a saída é o conteúdo do registrador.
    assign ReadData1 = (ReadAddress1 == 5'b0) ? 32'b0 : registers[ReadAddress1];

    // Porta de Leitura 2:
    // Se o endereço for 0, a saída é 0. Caso contrário, a saída é o conteúdo do registrador.
    assign ReadData2 = (ReadAddress2 == 5'b0) ? 32'b0 : registers[ReadAddress2];

endmodule
