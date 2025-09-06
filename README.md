# Processador MIPS com Pipeline

Este repositório contém o projeto de um **Processador MIPS de 32 bits com pipeline de 5 estágios**, desenvolvido em Verilog. O objetivo é implementar uma arquitetura MIPS simplificada e educacional, com suporte a instruções básicas, controle de fluxo e gerenciamento de riscos.

## 📌 Estágios do Pipeline

O pipeline é dividido em 5 estágios clássicos:

1. **IF** (Instruction Fetch) - Busca da instrução na memória
2. **ID** (Instruction Decode) - Decodificação da instrução e leitura de registradores
3. **EX** (Execute) - Execução de operações aritméticas/lógicas e cálculo de endereços
4. **MEM** (Memory Access) - Acesso à memória de dados
5. **WB** (Write Back) - Escrita do resultado nos registradores
    ![Resultado Final do Processador MIPS pipeline ](Verilog/datapath3/Captura%20de%20tela%202025-07-16%20141404.png)



## 📁 Estrutura do Projeto

```bash
MIPS_Pipeline/
├── docs/                  # Documentação e diagramas
├── Verilog/               # Códigos-fonte em Verilog
│   ├── datapath3/          # versão de caminho de dados
│   ├── datapath2/          # versão de caminho de dados
│   ├── datapath1/          # versão de caminho de dados
│   ├── pc.v                # Program Counter (PC)
│   ├── if_stage.v          # Estágio de busca (IF)
│   ├── id_stage.v          # Estágio de decodificação (ID)
│   ├── ex_stage.v          # Estágio de execução (EX)
│   ├── mem_stage.v         # Estágio de memória (MEM)
│   ├── wb_stage.v          # Estágio de escrita (WB)
│   ├── hazard_unit.v       # Unidade de detecção de riscos
│   ├── forwarding_unit.v   # Unidade de forwarding
│   └── top.v               # Módulo principal (top-level)
├── testbench/             # Testbenches para simulação
└── README.md              # Este arquivo
