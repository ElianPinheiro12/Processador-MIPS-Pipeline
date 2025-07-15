
module ex_mem_register(
    // --- Sinais de Controle do Registrador ---
    input           clk,
    input           rst,    // Reset síncrono, ativo-alto (para consistência)
    input           en,     // Habilitação (sempre ativa no nosso design)

    // --- Entradas do Estágio EX ---
    input  [31:0]   alu_result_ex,
    input  [31:0]   write_data_ex,      // Era o 'read_data_2', agora passado para ser usado pelo 'sw'
    input  [4:0]    write_reg_addr_ex,

    // Sinais de controle vindos do estágio EX
    input           ctrl_MemToReg_ex,
    input           ctrl_RegWrite_ex,
    input           ctrl_MemRead_ex,
    input           ctrl_MemWrite_ex,

    // --- Saídas para o Estágio MEM ---
    // Devem ser 'reg' porque são atribuídas dentro de um bloco 'always'
    output reg [31:0]   alu_result_mem,
    output reg [31:0]   write_data_mem,
    output reg [4:0]    write_reg_addr_mem,

    // Sinais de controle que seguirão para o estágio MEM
    output reg          ctrl_MemToReg_mem,
    output reg          ctrl_RegWrite_mem,
    output reg          ctrl_MemRead_mem,
    output reg          ctrl_MemWrite_mem
);

    // Lógica do registrador: sensível à borda de subida do clock
    always @(posedge clk) begin
        // Reset síncrono: se rst estiver ativo, zera todas as saídas
        if (rst) begin
            alu_result_mem     <= 32'b0;
            write_data_mem     <= 32'b0;
            write_reg_addr_mem <= 5'b0;

            ctrl_MemToReg_mem  <= 1'b0;
            ctrl_RegWrite_mem  <= 1'b0;
            ctrl_MemRead_mem   <= 1'b0;
            ctrl_MemWrite_mem  <= 1'b0;
        end
        // Se habilitado, captura os valores da entrada
        else if (en) begin
            // Passa os valores da entrada (EX) para a saída (MEM)
            alu_result_mem     <= alu_result_ex;
            write_data_mem     <= write_data_ex;
            write_reg_addr_mem <= write_reg_addr_ex;

            // Também passa os sinais de controle para o próximo estágio
            ctrl_MemToReg_mem  <= ctrl_MemToReg_ex;
            ctrl_RegWrite_mem  <= ctrl_RegWrite_ex;
            ctrl_MemRead_mem   <= ctrl_MemRead_ex;
            ctrl_MemWrite_mem  <= ctrl_MemWrite_ex;
        end
        // Se 'en' for falso, os registradores mantêm seu valor anterior
    end

endmodule
