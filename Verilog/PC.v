module PC (
    // --- Entradas ---
    input wire         clk,              // Sinal de clock do sistema
    input wire         rst,              // Sinal de reset (ativo em alto)
    input wire [1:0]   PCSrc,            // Sinal de controle para selecionar a fonte do próximo PC
    input wire [31:0]  branch_target_i,  // Endereço de destino do branch (calculado fora)
    input wire [31:0]  jump_target_i,    // Endereço de destino do jump (calculado fora)
    input wire [31:0]  jr_target_i,      // Endereço de destino do jump register (vindo do RegFile)

    // --- Saída ---
    output wire [31:0] pc_o              // Saída do PC atual (para a memória de instrução)
);

    // --- Sinais Internos ---
    reg  [31:0] pc_reg;        // Registrador que armazena o valor atual do PC
    wire [31:0] pc_plus_4_w;   // Valor de PC + 4
    reg  [31:0] pc_next_w;     // Próximo valor do PC (selecionado pelo MUX)

    // --- Definição dos códigos de controle ---
    localparam S_PC_PLUS_4 = 2'b00; // Seleciona PC + 4
    localparam S_BRANCH    = 2'b01; // Seleciona o alvo do branch
    localparam S_JUMP      = 2'b10; // Seleciona o alvo do jump
    localparam S_JR        = 2'b11; // Seleciona o alvo do jump register

    // --- Lógica Combinacional ---
    assign pc_plus_4_w = pc_reg + 32'd4;

    always @(*) begin
        case (PCSrc)
            S_PC_PLUS_4: pc_next_w = pc_plus_4_w;
            S_BRANCH:    pc_next_w = branch_target_i;
            S_JUMP:      pc_next_w = jump_target_i;
            S_JR:        pc_next_w = jr_target_i;
            default:     pc_next_w = pc_plus_4_w;
        endcase
    end

    // --- Lógica Sequencial ---
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_reg <= 32'h00000000;
        end else begin
            pc_reg <= pc_next_w;
        end
    end

    // --- Saída ---
    assign pc_o = pc_reg;

endmodule
