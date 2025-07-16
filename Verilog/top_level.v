/**
 * @file top.v
 * @brief Toplevel para um processador MIPS de 5 estágios com pipeline.
 * @details Inclui tratamento de hazards de dados (forwarding), hazards de carga-uso (stall/bubble),
 *          e hazards de controle (branch/jump com flush).
 */
module top(
    input        clk,
    input        rst,

    // --- Saídas para Depuração ---
    // Permitem observar sinais importantes em um simulador ou FPGA.
    output [31:0] debug_pc_if,               // PC atual no estágio IF
    output [31:0] debug_instruction_id,      // Instrução no estágio ID
    output [31:0] debug_alu_result_ex,       // Resultado da ALU no estágio EX
    output [31:0] debug_fwd_a_ex,            // Valor final na porta A da ALU (após forwarding)
    output [31:0] debug_fwd_b_ex,            // Valor final na porta B da ALU (após forwarding)
    output [31:0] debug_write_data_wb        // Dado final sendo escrito no banco de registradores
);

    //==========================================================================
    // SINAIS E FIOS (organizados por estágio)
    //==========================================================================

    // --- Sinais Comuns / Unidades de Controle ---
    wire        pc_write_enable;
    wire        if_id_write_enable;
    wire        id_ex_flush;
    wire        pipeline_flush_if;      // Sinal para anular a instrução no estágio IF (devido a branch/jump)
    wire [1:0]  forward_a_ctrl_ex;
    wire [1:0]  forward_b_ctrl_ex;

    // --- Estágio IF (Instruction Fetch) ---
    wire [31:0] pc_current_if, pc_plus_4_if, pc_next_if;
    wire [31:0] instruction_if;
    
    // --- Estágio ID (Instruction Decode) ---
    wire [31:0] pc_plus_4_id, instruction_id;
    wire [31:0] read_data_1_id, read_data_2_id, immediate_extended_id;
    wire [31:0] jump_target_addr_id, jump_reg_target_addr_id;
    wire [5:0]  opcode_id, funct_id;
    wire [4:0]  rs_id, rt_id, rd_id;
    // Sinais de controle gerados no estágio ID
    wire        reg_dst_id, alu_src_id, mem_to_reg_id, reg_write_id, mem_read_id, mem_write_id;
    wire        branch_id, bne_id, jump_id, jump_reg_id, jal_id;
    wire [1:0]  alu_op_id;

    // --- Estágio EX (Execute) ---
    wire [31:0] pc_plus_4_ex, read_data_1_ex, read_data_2_ex, immediate_extended_ex;
    wire [31:0] branch_target_ex, alu_result_ex;
    wire [31:0] alu_input_a_ex, alu_input_b_ex, alu_fwd_b_source_ex;
    wire [5:0]  funct_ex;
    wire [4:0]  rs_ex, rt_ex, rd_ex;
    wire [4:0]  alu_control_ex;
    wire [4:0]  write_reg_addr_ex;
    // Sinais de controle propagados para o estágio EX
    wire        reg_dst_ex, alu_src_ex, mem_to_reg_ex, reg_write_ex, mem_read_ex, mem_write_ex;
    wire        branch_ex, bne_ex, jal_ex;
    wire [1:0]  alu_op_ex;
    wire        alu_zero_flag_ex, branch_condition_met_ex;

    // --- Estágio MEM (Memory Access) ---
    wire [31:0] pc_plus_4_mem, alu_result_mem, write_data_mem;
    wire [31:0] data_read_from_mem, data_forwarded_from_mem;
    wire [4:0]  write_reg_addr_mem;
    // Sinais de controle propagados para o estágio MEM
    wire        mem_to_reg_mem, reg_write_mem, mem_read_mem, mem_write_mem, jal_mem;

    // --- Estágio WB (Write Back) ---
    wire [31:0] pc_plus_4_wb, alu_result_wb, data_read_from_mem_wb;
    wire [31:0] write_data_to_reg_wb;
    wire [4:0]  write_reg_addr_wb, final_write_reg_addr_wb;
    // Sinais de controle propagados para o estágio WB
    wire        mem_to_reg_wb, reg_write_wb, jal_wb;

    // --- Associações de depuração (mais claras) ---
    assign debug_pc_if               = pc_current_if;
    assign debug_instruction_id      = instruction_id;
    assign debug_alu_result_ex       = alu_result_ex;
    assign debug_fwd_a_ex            = alu_input_a_ex;
    assign debug_fwd_b_ex            = alu_input_b_ex;
    assign debug_write_data_wb       = write_data_to_reg_wb;

    //==========================================================================
    // ESTÁGIO 1: IF - INSTRUCTION FETCH
    //==========================================================================

    // Lógica de seleção do próximo PC com prioridade: Desvios (EX) > Saltos (ID) > Incremental
    assign pc_next_if = branch_condition_met_ex ? branch_target_ex        :
                        jump_reg_id             ? jump_reg_target_addr_id :
                        jump_id                 ? jump_target_addr_id     :
                                                  pc_plus_4_if;
     
    pc pc_inst (
        .clk (clk), 
        .rst (rst), 
        .en  (pc_write_enable), 
        .d   (pc_next_if), 
        .q   (pc_current_if)
    );

    somador pc_plus_4_adder (
        .a   (pc_current_if), 
        .b   (32'd4), 
        .c   (pc_plus_4_if)
    );

    memoria_instrucao im_inst (
        .pc          (pc_current_if), 
        .instruction (instruction_if)
    );
    
    //==========================================================================
    // REGISTRADOR DE PIPELINE: IF/ID
    //==========================================================================
    
    // A instrução no estágio IF deve ser anulada se um desvio for tomado ou um salto for executado.
    assign pipeline_flush_if = branch_condition_met_ex | jump_id | jump_reg_id;
    
    if_id_register IF_ID_reg (
        .clk            (clk), 
        .rst            (rst), 
        .en             (if_id_write_enable), 
        .flush          (pipeline_flush_if),
        .pc_plus_4_if   (pc_plus_4_if), 
        .instruction_if (instruction_if),
        .pc_plus_4_id   (pc_plus_4_id), 
        .instruction_id (instruction_id)
    );
     
    //==========================================================================
    // ESTÁGIO 2: ID - INSTRUCTION DECODE & REGISTER FETCH
    //==========================================================================
    
    // Decodificação dos campos da instrução
    assign opcode_id = instruction_id[31:26];
    assign rs_id     = instruction_id[25:21];
    assign rt_id     = instruction_id[20:16];
    assign rd_id     = instruction_id[15:11];
    assign funct_id  = instruction_id[5:0];
    
    // Cálculo dos endereços de salto (J e JR)
    assign jump_target_addr_id     = {pc_plus_4_id[31:28], instruction_id[25:0], 2'b00};
    assign jump_reg_target_addr_id = read_data_1_id; // O endereço vem do registrador 'rs'

    control_unit ctrl_unit (
        .opcode   (opcode_id), 
        .funct    (funct_id), 
        .RegDst   (reg_dst_id), 
        .ALUSrc   (alu_src_id),
        .MemToReg (mem_to_reg_id), 
        .RegWrite (reg_write_id), 
        .MemRead  (mem_read_id), 
        .MemWrite (mem_write_id),
        .Branch   (branch_id),         // Para BEQ
        .BranchOnNotZero      (bne_id),
		  .Jump     (jump_id),		  // Para BNE
        .JumpReg  (jump_reg_id),
        .JalWrite      (jal_id),
		  .ALUOp    (alu_op_id)
    );

    register_file reg_file_ins (
        .clk          (clk), 
        .rst          (rst), 
        .write_enable (reg_write_wb),           // A escrita ocorre no estágio WB
        .read_reg_1   (rs_id),
        .read_reg_2   (rt_id),
        .write_reg    (final_write_reg_addr_wb),// Endereço de escrita vem do estágio WB
        .write_data   (write_data_to_reg_wb),   // Dado de escrita vem do estágio WB
        .read_data_1  (read_data_1_id),
        .read_data_2  (read_data_2_id)
    );

    sign_extender sign_ext (
        .in  (instruction_id[15:0]), 
        .out (immediate_extended_id)
    );
     
    //==========================================================================
    // REGISTRADOR DE PIPELINE: ID/EX
    //==========================================================================
     
    id_ex_register ID_EX_reg (
        .clk   (clk), 
        .rst   (rst), 
        .en    (1'b1), // Sempre habilitado, o controle de bolha é feito pelo 'flush'
        .flush (id_ex_flush),

        // --- Sinais de Entrada (do estágio ID) ---
        .pc_plus_4_id          (pc_plus_4_id), 
        .read_data_1_id        (read_data_1_id), 
        .read_data_2_id        (read_data_2_id),
        .immediate_id          (immediate_extended_id), 
        .rs_id                 (rs_id), 
        .rt_id                 (rt_id), 
        .rd_id                 (rd_id), 
        .funct_id              (funct_id),
        // Sinais de controle
        .ctrl_RegDst_id        (reg_dst_id), 
        .ctrl_ALUSrc_id        (alu_src_id), 
        .ctrl_MemToReg_id      (mem_to_reg_id),
        .ctrl_RegWrite_id      (reg_write_id), 
        .ctrl_MemRead_id       (mem_read_id), 
        .ctrl_MemWrite_id      (mem_write_id),
        .ctrl_Branch_id        (branch_id), 
        .ctrl_BranchOnNotZero_id           (bne_id), 
        .ctrl_ALUOp_id         (alu_op_id),
        .ctrl_JalWrite_id           (jal_id),
        
        // --- Sinais de Saída (para o estágio EX) ---
        .pc_plus_4_ex          (pc_plus_4_ex), 
        .read_data_1_ex        (read_data_1_ex), 
        .read_data_2_ex        (read_data_2_ex),
        .immediate_ex          (immediate_extended_ex), 
        .rs_ex                 (rs_ex), 
        .rt_ex                 (rt_ex), 
        .rd_ex                 (rd_ex), 
        .funct_ex              (funct_ex),
        // Sinais de controle
        .ctrl_RegDst_ex        (reg_dst_ex), 
        .ctrl_ALUSrc_ex        (alu_src_ex), 
        .ctrl_MemToReg_ex      (mem_to_reg_ex),
        .ctrl_RegWrite_ex      (reg_write_ex), 
        .ctrl_MemRead_ex       (mem_read_ex), 
        .ctrl_MemWrite_ex      (mem_write_ex),
        .ctrl_Branch_ex        (branch_ex), 
        .ctrl_BranchOnNotZero_ex           (bne_ex), 
        .ctrl_ALUOp_ex         (alu_op_ex),
        .ctrl_JalWrite_ex           (jal_ex)
    );

    //==========================================================================
    // ESTÁGIO 3: EX - EXECUTE
    //==========================================================================
    
    // --- Unidade de Forwarding ---
    // Determina se os operandos da ALU devem vir do pipeline (MEM, WB) em vez do banco de registradores.
    forwarding_unit fwd_unit (
        .rs_ex              (rs_ex), 
        .rt_ex              (rt_ex), 
        .write_reg_addr_mem (write_reg_addr_mem),
        .reg_write_mem      (reg_write_mem), 
        .write_reg_addr_wb  (final_write_reg_addr_wb),
        .reg_write_wb       (reg_write_wb), 
        .forward_a          (forward_a_ctrl_ex), 
        .forward_b          (forward_b_ctrl_ex)
    );

    // --- Mux de Forwarding para Operando A ---
    mux3_1 #(.WIDTH(32)) fwd_a_mux (
        .sel (forward_a_ctrl_ex), 
        .in0 (read_data_1_ex),           // 00: Valor do registrador (sem forwarding)
        .in1 (write_data_to_reg_wb),     // 01: Valor do estágio WB
        .in2 (data_forwarded_from_mem),  // 10: Valor do estágio MEM
        .out (alu_input_a_ex)
    );
    
    // --- Mux de Forwarding para a fonte do Operando B ---
    mux3_1 #(.WIDTH(32)) fwd_b_mux_source (
        .sel (forward_b_ctrl_ex), 
        .in0 (read_data_2_ex),           // 00: Valor do registrador (sem forwarding)
        .in1 (write_data_to_reg_wb),     // 01: Valor do estágio WB
        .in2 (data_forwarded_from_mem),  // 10: Valor do estágio MEM
        .out (alu_fwd_b_source_ex)
    );

    // Seleção do Operando B da ALU: pode ser o valor do registrador (com forwarding) ou o imediato estendido.
    assign alu_input_b_ex = alu_src_ex ? immediate_extended_ex : alu_fwd_b_source_ex;

    // --- Controle e Instância da ALU ---
    alu_control alu_ctrl_unit (
        .alu_op      (alu_op_ex), 
        .funct       (funct_ex), 
        .alu_control (alu_control_ex)
    );
    
    alu alu_inst (
        .a      (alu_input_a_ex), 
        .b      (alu_input_b_ex), 
        .op     (alu_control_ex), 
        .result (alu_result_ex), 
        .zero   (alu_zero_flag_ex)
    );
    
    // --- Lógica de Desvio (Branch) ---
    // Mux para o registrador de destino: rd para R-type, rt para I-type
    assign write_reg_addr_ex = reg_dst_ex ? rd_ex : rt_ex;
    
    // Somador para calcular o endereço de destino do desvio
    somador branch_adder (
        .a   (pc_plus_4_ex), 
        .b   (immediate_extended_ex << 2), 
        .c   (branch_target_ex)
    );
    
    // Lógica final que decide se o desvio deve ser tomado (para BEQ e BNE)
    assign branch_condition_met_ex = (branch_ex & alu_zero_flag_ex) | (bne_ex & ~alu_zero_flag_ex);

    //==========================================================================
    // REGISTRADOR DE PIPELINE: EX/MEM
    //==========================================================================
     
    ex_mem_register EX_MEM_reg (
        .clk   (clk), 
        .rst   (rst), 
        .en    (1'b1),

        // --- Sinais de Entrada (do estágio EX) ---
        .pc_plus_4_ex      (pc_plus_4_ex),
        .alu_result_ex     (alu_result_ex), 
        .write_data_ex     (alu_fwd_b_source_ex), // Dado a ser escrito na memória (vem do operando B com fwd)
        .write_reg_addr_ex (write_reg_addr_ex),
        .ctrl_MemToReg_ex  (mem_to_reg_ex), 
        .ctrl_RegWrite_ex  (reg_write_ex), 
        .ctrl_MemRead_ex   (mem_read_ex),
        .ctrl_MemWrite_ex  (mem_write_ex),
        .ctrl_JalWrite_ex       (jal_ex),
        
        // --- Sinais de Saída (para o estágio MEM) ---
        .pc_plus_4_mem      (pc_plus_4_mem), 
        .alu_result_mem     (alu_result_mem), 
        .write_data_mem     (write_data_mem),
        .write_reg_addr_mem (write_reg_addr_mem), 
        .ctrl_MemToReg_mem  (mem_to_reg_mem),
        .ctrl_RegWrite_mem  (reg_write_mem), 
        .ctrl_MemRead_mem   (mem_read_mem),
        .ctrl_MemWrite_mem  (mem_write_mem),
        .ctrl_JalWrite_mem       (jal_mem)
    );
     
    //==========================================================================
    // ESTÁGIO 4: MEM - MEMORY ACCESS
    //==========================================================================
    
    // Este dado é usado para o forwarding da MEM para a EX
    assign data_forwarded_from_mem = alu_result_mem; // Para R-type, o valor a ser encaminhado é o resultado da ALU

    data_memory data_mem_inst (
        .clk        (clk), 
        .address    (alu_result_mem),      // Endereço calculado pela ALU
        .write_data (write_data_mem),      // Dado a ser escrito (para SW)
        .mem_write  (mem_write_mem),       // Sinal de controle para escrita
        .mem_read   (mem_read_mem),        // Sinal de controle para leitura
        .read_data  (data_read_from_mem) // Dado lido da memória (para LW)
    );

    //==========================================================================
    // REGISTRADOR DE PIPELINE: MEM/WB
    //==========================================================================
     
    mem_wb_register MEM_WB_reg (
        .clk   (clk), 
        .rst   (rst), 
        .en    (1'b1),

        // --- Sinais de Entrada (do estágio MEM) ---
        .pc_plus_4_mem        (pc_plus_4_mem),
        .read_data_mem        (data_read_from_mem), 
        .alu_result_mem       (alu_result_mem),
        .write_reg_addr_mem   (write_reg_addr_mem), 
        .ctrl_MemToReg_mem    (mem_to_reg_mem),
        .ctrl_RegWrite_mem    (reg_write_mem),
        .ctrl_JalWrite_mem         (jal_mem),
        
        // --- Sinais de Saída (para o estágio WB) ---
        .pc_plus_4_wb         (pc_plus_4_wb), 
        .read_data_wb         (data_read_from_mem_wb), 
        .alu_result_wb        (alu_result_wb),
        .write_reg_addr_wb    (write_reg_addr_wb), 
        .ctrl_MemToReg_wb     (mem_to_reg_wb),
        .ctrl_RegWrite_wb     (reg_write_wb),
        .ctrl_JalWrite_wb          (jal_wb)
    );

    //==========================================================================
    // ESTÁGIO 5: WB - WRITE BACK
    //==========================================================================
     
    // Mux final: O que vai ser escrito no registrador? O resultado da memória (LW) ou da ALU (R-Type)?
    wire [31:0] result_from_mem_or_alu;
    assign result_from_mem_or_alu = mem_to_reg_wb ? data_read_from_mem_wb : alu_result_wb;

    // Lógica completa de escrita: para JAL, escreve PC+4; para os demais, o resultado do mux anterior.
    assign write_data_to_reg_wb    = jal_wb ? pc_plus_4_wb : result_from_mem_or_alu;
    
    // Para JAL, o registrador de destino é sempre $ra (31). Para os demais, é o que veio do pipeline.
    assign final_write_reg_addr_wb = jal_wb ? 5'd31 : write_reg_addr_wb;
     
    //==========================================================================
    // UNIDADE DE DETECÇÃO DE HAZARD (LOAD-USE)
    //==========================================================================
     
    hazard_detection_unit hazard_unit (
        .id_ex_mem_read (mem_read_ex),           // A instrução no estágio EX é um LW?
        .id_ex_rt       (rt_ex),                 // Qual o registrador de destino dela (rt)?
        .if_id_rs       (rs_id),                 // A instrução em ID usa este registrador como fonte 1?
        .if_id_rt       (rt_id),                 // A instrução em ID usa este registrador como fonte 2?
        .pc_write       (pc_write_enable),       // Saída: trava o PC
        .if_id_write    (if_id_write_enable),    // Saída: trava o registrador IF/ID
        .id_ex_flush    (id_ex_flush)            // Saída: injeta uma bolha (NOP) em ID/EX
    );
     
endmodule
