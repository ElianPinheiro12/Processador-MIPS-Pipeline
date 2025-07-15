
module id_ex_register(
    // --- Sinais de Controle do Registrador ---
    input           clk,
    input           rst,
    input           en,     // Neste design, está sempre habilitado (1'b1), 
                            // pois o stall é controlado nos registradores anteriores.
    input           flush,  // Zera as saídas para injetar uma NOP (No-Operation)

    // --- Entradas do Estágio ID ---
    input  [31:0]   pc_plus_4_id,
    input  [31:0]   read_data_1_id,
    input  [31:0]   read_data_2_id,
    input  [31:0]   immediate_id,
    input  [4:0]    rs_id,
    input  [4:0]    rt_id,
    input  [4:0]    rd_id,

    // Sinais de controle vindos do estágio ID
    input           ctrl_RegDst_id,
    input           ctrl_ALUSrc_id,
    input           ctrl_MemToReg_id,
    input           ctrl_RegWrite_id,
    input           ctrl_MemRead_id,
    input           ctrl_MemWrite_id,
    input           ctrl_Branch_id,
	 input  [5:0]    funct_id,
    input  [1:0]    ctrl_ALUOp_id,

    // --- Saídas para o Estágio EX ---
    // Devem ser 'reg' porque são atribuídas dentro de um bloco 'always'
    output reg [31:0]   pc_plus_4_ex,
    output reg [31:0]   read_data_1_ex,
    output reg [31:0]   read_data_2_ex,
    output reg [31:0]   immediate_ex,
    output reg [4:0]    rs_ex,
    output reg [4:0]    rt_ex,
    output reg [4:0]    rd_ex,
    
    // Sinais de controle que seguirão para o estágio EX
    output reg          ctrl_RegDst_ex,
    output reg          ctrl_ALUSrc_ex,
    output reg          ctrl_MemToReg_ex,
    output reg          ctrl_RegWrite_ex,
    output reg          ctrl_MemRead_ex,
    output reg          ctrl_MemWrite_ex,
    output reg          ctrl_Branch_ex,
	  output reg [5:0]    funct_ex,
    output reg [1:0]    ctrl_ALUOp_ex
);

    // Lógica do registrador: sensível à borda de subida do clock
    always @(posedge clk) begin
        // Reset (assíncrono ou síncrono, dependendo do estilo)
        // Aqui está como um reset síncrono
        if (rst) begin
            // Zera todas as saídas no reset. Isso efetivamente
            // passa uma instrução NOP pelo pipeline.
            pc_plus_4_ex   <= 32'b0;
            read_data_1_ex <= 32'b0;
            read_data_2_ex <= 32'b0;
            immediate_ex   <= 32'b0;
            rs_ex          <= 5'b0;
            rt_ex          <= 5'b0;
            rd_ex          <= 5'b0;

            ctrl_RegDst_ex   <= 1'b0;
            ctrl_ALUSrc_ex   <= 1'b0;
            ctrl_MemToReg_ex <= 1'b0;
            ctrl_RegWrite_ex <= 1'b0;
            ctrl_MemRead_ex  <= 1'b0;
            ctrl_MemWrite_ex <= 1'b0;
            ctrl_Branch_ex   <= 1'b0;
				funct_ex         <= 6'b0;
            ctrl_ALUOp_ex    <= 2'b0;
        end 
        // A unidade de detecção de hazard ativa 'flush' para inserir uma bolha (NOP)
        else if (flush) begin
            // O comportamento do flush é o mesmo do reset: zerar tudo
            pc_plus_4_ex   <= 32'b0;
            read_data_1_ex <= 32'b0;
            read_data_2_ex <= 32'b0;
            immediate_ex   <= 32'b0;
            rs_ex          <= 5'b0;
            rt_ex          <= 5'b0;
            rd_ex          <= 5'b0;

            ctrl_RegDst_ex   <= 1'b0;
            ctrl_ALUSrc_ex   <= 1'b0;
            ctrl_MemToReg_ex <= 1'b0;
            ctrl_RegWrite_ex <= 1'b0;
            ctrl_MemRead_ex  <= 1'b0;
            ctrl_MemWrite_ex <= 1'b0;
            ctrl_Branch_ex   <= 1'b0;
				funct_ex         <= 6'b0;
            ctrl_ALUOp_ex    <= 2'b0;
        end
        // Operação normal: captura as entradas se habilitado
        else if (en) begin
            // Passa os valores da entrada (ID) para a saída (EX)
            pc_plus_4_ex   <= pc_plus_4_id;
            read_data_1_ex <= read_data_1_id;
            read_data_2_ex <= read_data_2_id;
            immediate_ex   <= immediate_id;
            rs_ex          <= rs_id;
            rt_ex          <= rt_id;
            rd_ex          <= rd_id;

            // Também passa os sinais de controle para o próximo estágio
            ctrl_RegDst_ex   <= ctrl_RegDst_id;
            ctrl_ALUSrc_ex   <= ctrl_ALUSrc_id;
            ctrl_MemToReg_ex <= ctrl_MemToReg_id;
            ctrl_RegWrite_ex <= ctrl_RegWrite_id;
            ctrl_MemRead_ex  <= ctrl_MemRead_id;
            ctrl_MemWrite_ex <= ctrl_MemWrite_id;
            ctrl_Branch_ex   <= ctrl_Branch_id;
				funct_ex         <= funct_id;
            ctrl_ALUOp_ex    <= ctrl_ALUOp_id;
        end
    end

endmodule
