
module if_id_register(
    // --- Sinais de Controle do Registrador ---
    input           clk,
    input           rst,          // Reset síncrono, ativo-alto
    input           en,           // Habilitação (controlado pela unidade de hazard para stall)
    input           flush,        // Limpa o registrador (usado após um branch ser tomado)

    // --- Entradas do Estágio IF ---
    input  [31:0]   pc_plus_4_if,
    input  [31:0]   instruction_if,

    // --- Saídas para o Estágio ID ---
    // Devem ser 'reg' porque são atribuídas dentro de um bloco 'always'
    output reg [31:0]   pc_plus_4_id,
    output reg [31:0]   instruction_id
);

    // Lógica do registrador: sensível à borda de subida do clock
    always @(posedge clk) begin
        // Reset síncrono: se rst estiver ativo, zera as saídas
        if (rst) begin
            pc_plus_4_id   <= 32'b0;
            instruction_id <= 32'b0; // Uma instrução NOP (sll $0, $0, 0)
        end
        // O flush tem prioridade sobre o enable. Usado para anular a instrução
        // que foi buscada indevidamente após um branch.
        else if (flush) begin
            pc_plus_4_id   <= 32'b0;
            instruction_id <= 32'b0; // Insere uma NOP
        end
        // Se habilitado e não em flush, captura os valores
        else if (en) begin
            pc_plus_4_id   <= pc_plus_4_if;
            instruction_id <= instruction_if;
        end
        // Se 'en' for falso (stall), os registradores mantêm seu valor anterior
    end

endmodule
