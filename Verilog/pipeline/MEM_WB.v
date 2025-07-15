module mem_wb_register(
    // --- Sinais de Controle do Registrador ---
    input           clk,
    input           rst,    // Reset síncrono, ativo-alto
    input           en,     // Habilitação (sempre ativa no nosso design)

    // --- Entradas do Estágio MEM ---
    input  [31:0]   read_data_mem,      // Dado lido da memória de dados
    input  [31:0]   alu_result_mem,     // Resultado da ALU, vindo do estágio anterior
    input  [4:0]    write_reg_addr_mem, // Endereço do registrador para escrever

    // Sinais de controle vindos do estágio MEM
    input           ctrl_MemToReg_mem,
    input           ctrl_RegWrite_mem,

    // --- Saídas para o Estágio WB ---
    // Devem ser 'reg' porque são atribuídas dentro de um bloco 'always'
    output reg [31:0]   read_data_wb,
    output reg [31:0]   alu_result_wb,
    output reg [4:0]    write_reg_addr_wb,

    // Sinais de controle que seguirão para o estágio WB
    output reg          ctrl_MemToReg_wb,
    output reg          ctrl_RegWrite_wb
);

    // Lógica do registrador: sensível à borda de subida do clock
    always @(posedge clk) begin
        // Reset síncrono: se rst estiver ativo, zera todas as saídas
        if (rst) begin
            read_data_wb      <= 32'b0;
            alu_result_wb     <= 32'b0;
            write_reg_addr_wb <= 5'b0;

            ctrl_MemToReg_wb  <= 1'b0;
            ctrl_RegWrite_wb  <= 1'b0;
        end
        // Se habilitado, captura os valores da entrada
        else if (en) begin
            // Passa os valores da entrada (MEM) para a saída (WB)
            read_data_wb      <= read_data_mem;
            alu_result_wb     <= alu_result_mem;
            write_reg_addr_wb <= write_reg_addr_mem;

            // Também passa os sinais de controle finais para o estágio WB
            ctrl_MemToReg_wb  <= ctrl_MemToReg_mem;
            ctrl_RegWrite_wb  <= ctrl_RegWrite_mem;
        end
    end

endmodule
